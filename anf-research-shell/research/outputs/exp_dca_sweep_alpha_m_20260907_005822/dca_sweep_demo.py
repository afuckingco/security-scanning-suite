#!/usr/bin/env python3
"""DCA — sweep alpha/m + biaya state dim (bukti H5, eksperimen JSI3 no.3).

Rule finite-memory m=1: W_{k+1} = 1 + α·1_{R_k<0}.
- Rekursi 1-d NAIF (kernel rata-rata salah, hbar=1+α/2): seharusnya GAGAL
  untuk α>0 (state B saja tak cukup).
- Rekursi 2-state: state = (y, z), z = tanda increment terakhir; dua densitas
  terkopel p(z=0), p(z=1); transisi z' = tanda R_{k+1} fair (1/2) →
    p'(y', z') = (1/2)·Σ_z ∫ p_z(y) K_z(y→y') dy,  h_z = 1 + α·1_{z=1}.
  Biaya ~ 2×1-d = O(2·G²) per langkah vs O(G²) utk m=0.
- Kontrol: α=0 → W≡1 (m tidak relevan; 1-d harus cocok juga).

Validasi vs MC (N=10^6, 120 langkah): W1_log + quantile gap + runtime.

Output: research/outputs/dca_sweep_mc.json + .png
"""
import json
import time

import numpy as np
from scipy import stats

SEED = 42
N_MC = 1_000_000
STEPS = 120
SIGMA = 0.15
ALPHAS = (0.0, 0.5, 1.0)
G = 600
QV = (0.1, 0.5, 0.9)

OUT_JSON = "research/outputs/dca_sweep_mc.json"
OUT_PNG = "research/outputs/dca_sweep_mc.png"


def q_norm(r):
    return stats.norm.pdf(r, loc=0.0, scale=SIGMA)


def mc_terminal(alpha):
    rng = np.random.default_rng(SEED)
    B = np.ones(N_MC)
    prev_neg = np.zeros(N_MC, dtype=bool)
    for k in range(STEPS):
        R = rng.normal(0.0, SIGMA, size=N_MC)
        W = np.ones(N_MC) if k == 0 else 1.0 + alpha * prev_neg
        B = np.exp(R) * B + W
        prev_neg = R < 0
    return B


def log_grid(log_samples):
    """Grid log yang memuat titik awal Dirac y=0 (jebakan terdokumentasi)."""
    ymin = min(float(np.quantile(log_samples, 0.0005)), 0.0) - 0.05
    ymax = float(np.quantile(log_samples, 0.9999)) + 0.02
    ys = np.linspace(ymin, ymax, G)
    return ys, ys[1] - ys[0]


def kernel_const(y, h, neg=None):
    """Kernel log untuk W konstan h: K[i,j] = q(r)·b'_j/(b'_j-h), b'_j>h.

    neg=None -> semua r (rekursi 1-d biasa);
    neg=True  -> hanya massa dengan r<0 (z'=1);
    neg=False -> hanya r>=0 (z'=0).
    Jebakan: tanda increment baru TIDAK independen dari y'; r ditentukan
    unik oleh (y,y',z) -> joint (y',z') harus dipisah lewat tanda r.
    """
    bb = np.exp(y)[:, None]
    bc = np.exp(y)[None, :]
    valid = bc > h
    r = np.log(np.where(valid, (bc - h) / bb, 1.0))
    if neg is None:
        mask = np.ones_like(valid)
    else:
        mask = (r < 0) if neg else (r >= 0)
    return np.where(valid & mask, q_norm(r) * bc / (bc - h), 0.0)


def recursion_naive(y, dy, hbar):
    p = np.zeros(G)
    p[int(np.argmin(np.abs(y - 0.0)))] = 1.0 / dy
    K = kernel_const(y, hbar)
    for _ in range(STEPS):
        p = (p @ K) * dy
        p /= p.sum() * dy
    return np.cumsum(p) * dy


def recursion_2state(y, dy, h0, h1):
    """State (y, z), z = tanda increment terakhir (1 = negatif, W = 1+α).

    Transisi benar: massa oleh r<0 masuk z'=1, r>=0 masuk z'=0.
    """
    p0 = np.zeros(G)
    p0[int(np.argmin(np.abs(y - 0.0)))] = 1.0 / dy
    p1 = np.zeros(G)
    K0p, K0n = kernel_const(y, h0, False), kernel_const(y, h0, True)
    K1p, K1n = kernel_const(y, h1, False), kernel_const(y, h1, True)
    for _ in range(STEPS):
        n0 = (p0 @ K0p + p1 @ K1p) * dy   # z'=0: r >= 0
        n1 = (p0 @ K0n + p1 @ K1n) * dy   # z'=1: r < 0
        p0, p1 = n0, n1
        s = (p0.sum() + p1.sum()) * dy
        if s > 0:
            p0, p1 = p0 / s, p1 / s
    return np.cumsum((p0 + p1) * dy)


def ecdf(grid, samples):
    s = np.sort(samples)
    return np.searchsorted(s, grid) / len(s)


def w1(grid, cdf, samples):
    s = np.sort(samples)
    ec = np.searchsorted(s, grid) / len(s)
    return float(np.mean(np.abs(cdf - ec)) * (grid[-1] - grid[0]))


def qgap(grid, cdf, samples):
    qr = np.exp(np.interp(QV, cdf, grid))
    return [float(qr[i] - np.quantile(samples, QV[i])) for i in range(3)]


def main():
    res_rows = []
    for alpha in ALPHAS:
        mc = mc_terminal(alpha)
        ls = np.log(mc)
        y, dy = log_grid(ls)
        t0 = time.perf_counter()
        cdf_n = recursion_naive(y, dy, 1.0 + alpha / 2.0)
        t1 = time.perf_counter()
        cdf_2 = recursion_2state(y, dy, 1.0, 1.0 + alpha)
        t2 = time.perf_counter()
        row = {
            "alpha": alpha,
            "naive_1d_w1": w1(y, cdf_n, ls),
            "naive_1d_cost_s": round(t1 - t0, 3),
            "two_state_w1": w1(y, cdf_2, ls),
            "two_state_qgap": [round(x, 3) for x in qgap(y, cdf_2, mc)],
            "two_state_cost_s": round(t2 - t1, 3),
        }
        res_rows.append(row)
        print(f"alpha={alpha}: naive W1={row['naive_1d_w1']:.4f} | "
              f"2-state W1={row['two_state_w1']:.4f} | qgap={row['two_state_qgap']} | "
              f"cost 2-state={row['two_state_cost_s']}s | grid {y[0]:.2f}..{y[-1]:.2f}")

    with open(OUT_JSON, "w") as f:
        json.dump({"seed": SEED, "mc_n": N_MC, "steps": STEPS, "sigma": SIGMA,
                   "G": G, "quantiles": list(QV), "results": res_rows}, f, indent=2)

    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    ax = plt.subplots(figsize=(6.6, 3.4))[1]
    xx = np.arange(len(ALPHAS))
    w = 0.35
    ax.bar(xx - w / 2, [r["naive_1d_w1"] for r in res_rows], w,
           label="rekursi 1-d naif (salah)", color="#DD8452")
    ax.bar(xx + w / 2, [r["two_state_w1"] for r in res_rows], w,
           label="rekursi 2-state (benar)", color="#4C72B0")
    for i, r in enumerate(res_rows):
        ax.text(i - w / 2, r["naive_1d_w1"] + 0.002, f"{r['naive_1d_w1']:.3f}",
                ha="center", fontsize=8)
        ax.text(i + w / 2, r["two_state_w1"] + 0.002, f"{r['two_state_w1']:.3f}",
                ha="center", fontsize=8)
    ax.set_xticks(xx, [f"α={a:g}" for a in ALPHAS])
    ax.set_ylabel("W1 (ruang log)")
    ax.set_title("Rule m=1 (1_{R_k<0}): rekursi 1-d naif gagal, 2-state cocok")
    ax.legend(fontsize=8)
    ax.grid(alpha=0.3, lw=0.5, axis="y")
    plt.tight_layout()
    plt.savefig(OUT_PNG, dpi=300, bbox_inches="tight")
    print("plot:", OUT_PNG)


if __name__ == "__main__":
    main()