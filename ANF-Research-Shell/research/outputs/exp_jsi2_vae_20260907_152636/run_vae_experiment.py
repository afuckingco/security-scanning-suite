#!/usr/bin/env python3
"""Eksperimen validasi empiris JSI2 — VAE pada campuran Gaussian 2D.

Bukti lapisan 2 (mekanika statistik -> variational inference):
- Model: VAE (encoder q_phi(z|x), decoder p_theta(x|z)), ELBO.
- Data: campuran 6 Gaussian di R^2 (terinspirasi "data multi-modal").
- Metrik: ELBO akhir (nats), MSE rekonstruksi, KL rata-rata,
  kualitas sampel via jarak Wasserstein-2 ke data asli (approx).
- Seed tetap untuk reprodusibilitas.
Output: research/outputs/jsi2_vae_exp.json + figures/jsi2_vae_loss.png
"""
import json
import math
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

SEED = 42
torch.manual_seed(SEED)
np.random.seed(SEED)

OUT_JSON = "research/outputs/jsi2_vae_exp.json"
OUT_PNG = "submissions/jsi2/figures/fig2_vae_loss.png"

# ---------- Data: campuran 6 Gaussian 2D ----------
N = 3000
centers = np.array([
    [2.0, 2.0], [-2.0, 2.0], [2.0, -2.0],
    [-2.0, -2.0], [0.0, 3.5], [0.0, -3.5],
])
k = len(centers)
comp = np.random.randint(0, k, size=N)
X = centers[comp] + 0.35 * np.random.randn(N, 2)
torch_X = torch.tensor(X, dtype=torch.float32)


class Encoder(nn.Module):
    def __init__(self, d=2, h=64, z=2):
        super().__init__()
        self.fc1 = nn.Linear(d, h)
        self.mu = nn.Linear(h, z)
        self.logvar = nn.Linear(h, z)

    def forward(self, x):
        h = F.relu(self.fc1(x))
        return self.mu(h), self.logvar(h)


class Decoder(nn.Module):
    def __init__(self, z=2, h=64, d=2):
        super().__init__()
        self.fc1 = nn.Linear(z, h)
        self.out = nn.Linear(h, d)

    def forward(self, z):
        h = F.relu(self.fc1(z))
        return self.out(h)


def objective(model, x, beta=1.0):
    """Objektif pelatihan = rekonstruksi (MSE) + beta*KL = NEGATIF ELBO
    (tanpa konstanta konstanta likelihood Gaussian). ELBO dimaksimalkan,
    objektif ini diminimalkan -> kurva menurun."""
    enc, dec = model
    mu, logvar = enc(x)
    z = mu + torch.exp(0.5 * logvar) * torch.randn_like(mu)
    recon = dec(z)
    recon_loss = F.mse_loss(recon, x, reduction="sum") / x.size(0)
    kl = -0.5 * torch.sum(1 + logvar - mu.pow(2) - logvar.exp(), dim=1).mean()
    return recon_loss + beta * kl, recon_loss.item(), kl.item()


def sample(model, n=1000):
    enc, dec = model
    z = torch.randn(n, 2)
    return dec(z).detach().numpy()


def wasserstein2(a, b):
    """Perkiraan W2 antar dua sampel: L2 jarak pasangan terdekat rata-rata."""
    # greedy: untuk tiap a, jarak min ke b (bukan W2 sejati, tapi indikator monote)
    a = torch.tensor(a, dtype=torch.float32)
    b = torch.tensor(b, dtype=torch.float32)
    d = torch.cdist(a, b).min(dim=1).values.mean().item()
    return d


def main():
    torch.manual_seed(SEED)
    enc, dec = Encoder(), Decoder()
    model = (enc, dec)
    opt = torch.optim.Adam(list(enc.parameters()) + list(dec.parameters()), lr=1e-3)

    epochs = 120
    losses = []
    elbo_vals = []
    batch = 256
    for ep in range(epochs):
        perm = torch.randperm(N)
        ep_recon, ep_kl = 0.0, 0.0
        nb = 0
        for i in range(0, N, batch):
            idx = perm[i:i + batch]
            xb = torch_X[idx]
            opt.zero_grad()
            loss, rc, kl = objective(model, xb)
            loss.backward()
            opt.step()
            ep_recon += rc * len(idx)
            ep_kl += kl * len(idx)
            nb += len(idx)
        ep_recon /= nb
        ep_kl /= nb
        elbo_vals.append(ep_recon + ep_kl)
        losses.append((ep_recon, ep_kl))
        if ep % 20 == 0:
            print(f"ep {ep:3d} | recon {ep_recon:.4f} | kl {ep_kl:.4f} | obj(-ELBO) {ep_recon+ep_kl:.4f}")

    # metrik akhir
    with torch.no_grad():
        mu, logvar = enc(torch_X)
        z = mu + torch.exp(0.5 * logvar) * torch.randn_like(mu)
        recon_X = dec(z).numpy()
    mse_final = float(np.mean((recon_X - X) ** 2))
    # KL = -0.5 * sum(1 + logvar - mu^2 - exp(logvar)) — TANDA MINUS di depan
    kl_final = float((-0.5 * (1 + logvar - mu.pow(2) - logvar.exp()).sum(dim=1)).mean().item())
    samples = sample(model)
    w2 = wasserstein2(X[:1000], samples[:1000])
    elbo_final = elbo_vals[-1]

    result = {
        "seed": SEED,
        "data": "mixture of 6 Gaussians in R^2",
        "n_samples": N,
        "model": "VAE (encoder MLP 64, decoder MLP 64, latent 2)",
        "optimizer": "Adam lr=1e-3",
        "epochs": epochs,
        "batch_size": batch,
        "elbo_final": round(elbo_final, 4),
        "recon_mse_final": round(mse_final, 4),
        "kl_final": round(kl_final, 4),
        "wasserstein2_approx": round(w2, 4),
        "objective_note": "objective = recon_mse + kl = negative ELBO (tanpa konstanta likelihood); menurun saat pelatihan",
    }
    with open(OUT_JSON, "w") as f:
        json.dump(result, f, indent=2)
    print(json.dumps(result, indent=2))

    # plot
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt
    plt.rcParams.update({
        "font.size": 9, "axes.titlesize": 10, "axes.labelsize": 9,
        "legend.fontsize": 8, "xtick.labelsize": 8, "ytick.labelsize": 8,
        "axes.linewidth": 0.8,
    })
    C_BLUE, C_ORANGE = "#4C72B0", "#DD8452"
    fig, ax = plt.subplots(1, 2, figsize=(9, 3.6))
    ax[0].plot(range(epochs), elbo_vals, lw=1.8, color=C_BLUE)
    ax[0].set_xlabel("epoch")
    ax[0].set_ylabel("objektif (rekonstruksi + KL)")
    ax[0].set_title("Kurva objektif pelatihan VAE (-ELBO)")
    ax[0].grid(alpha=0.3, lw=0.6)
    ax[1].scatter(X[:, 0], X[:, 1], s=8, alpha=0.55, color=C_BLUE, label="data")
    ax[1].scatter(samples[:, 0], samples[:, 1], s=8, alpha=0.55, color=C_ORANGE, label="sampel VAE")
    ax[1].set_aspect("equal", adjustable="datalim")
    ax[1].grid(alpha=0.3, lw=0.6)
    ax[1].legend(framealpha=0.9)
    ax[1].set_title("Data vs sampel VAE")
    plt.tight_layout()
    import os
    os.makedirs("submissions/jsi2/figures", exist_ok=True)
    plt.savefig(OUT_PNG, dpi=300, bbox_inches="tight")
    print("plot:", OUT_PNG)


if __name__ == "__main__":
    main()