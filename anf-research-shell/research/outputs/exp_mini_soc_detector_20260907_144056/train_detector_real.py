#!/usr/bin/env python3
"""Latih detektor 40-fitur per-paket yang SEHAT (menggantikan xgboost_model.json degenerate).

Masalah ditemukan 2026-08-26: xgboost_model.json yang ter-commit punya 100 pohon
dengan 0 SPLIT -> output KONSTAN p_ids=0.9691 utk input apa pun. Semua eksperimen
ESR/FVR yg memakainya (timesteps 21 run dst.) mengevaluasi DRL melawan detektor
yang tidak bisa membedakan apa pun -> klaim "robust di problem-space" VACUOUS.

Script ini:
1) Membangkitkan dataset seimbang dari ruang parameter paket (benign vs anomali)
   dengan aturan domain yang JELAS & reproducible (seed 42):
     BENIGN  = frag==0 AND ttl in [48,128] AND window>=8192
               AND flags in {S,SA,A,PA} AND payload<=64
               AND dport in web-ports {80,443,8080,8082,8443}
     ANOMALI = selain itu (fragmentation, TTL ekstrem, window kecil,
               flags R/F/FA, payload besar, port non-web, UDP dgn payload)
2) Melatih XGBoost (n_estimators=200, max_depth=6, lr=0.08, seed 42, n_jobs=1)
3) Menyimpan model + norm_params (min/max data latih utk observasi agent)
4) AUDIT: jumlah split > 0 (bukan degenerate), AUC/acc/prec/rec holdout,
   p_ids non-konstan atas 2000 paket acak -> bukti detektor bisa membedakan.
Resource: n_jobs=1, tanpa GPU, dataset kecil (<1 mnt).
"""
from __future__ import annotations

import gc
import json
import os
import sys
import time
from pathlib import Path

import numpy as np
import psutil

ROOT = Path(__file__).resolve().parents[3]
SRC = ROOT / "code" / "adversarial-traffic-generator" / "src"
sys.path.insert(0, str(SRC))

from scapy.all import Ether, IP, TCP, UDP, Raw

SEED = 42
N_SAMPLES = 12000  # 6000 benign + 6000 anomali (target)
MODEL_DIR = ROOT / "code" / "mini-soc-enterprise-arch" / "ml_detector"
MODEL_PATH = MODEL_DIR / "xgboost_model.json"
WEB_PORTS = [80, 443, 8080, 8082, 8443, 8088]
ANOM_PORTS = [21, 22, 25, 53, 445, 1433, 3389, 6667, 31337, 4444]
FLAG_BENIGN = ["S", "SA", "A", "PA"]
FLAG_ANOM = ["R", "F", "FA", "S", "SA", "P"]


def extract40(pkt) -> np.ndarray:
    """Ekstraksi 40 fitur per-paket — SAMA dengan ids_env._packet_to_unswnb_features."""
    f = np.zeros(40, dtype=np.float32)
    ip_layer = pkt["IP"]
    total_length = float(ip_layer.len)
    ttl_v = float(ip_layer.ttl)
    frag_v = float(ip_layer.frag)
    proto_v = float(ip_layer.proto)
    if pkt.haslayer("TCP"):
        tcp = pkt["TCP"]
        window_v = float(tcp.window)
        flags_v = int(tcp.flags)
        sport_v = float(tcp.sport)
        dport_v = float(tcp.dport)
    else:
        udp_l = pkt["UDP"]
        window_v = 0.0
        flags_v = 0.0
        sport_v = float(udp_l.sport)
        dport_v = float(udp_l.dport)
    padding_len = float(len(pkt["Raw"])) if pkt.haslayer("Raw") else 0.0
    f[0] = total_length; f[1] = ttl_v; f[2] = window_v; f[3] = flags_v
    f[4] = sport_v; f[5] = dport_v; f[6] = frag_v; f[7] = padding_len; f[8] = proto_v
    f[9] = total_length / ttl_v if ttl_v > 0 else 0.0
    f[10] = total_length / window_v if window_v > 0 else 0.0
    f[11] = bin(int(flags_v)).count("1")
    f[12] = sport_v / dport_v if dport_v > 0 else 0.0
    f[13] = dport_v / sport_v if sport_v > 0 else 0.0
    f[14] = ttl_v / window_v if window_v > 0 else 0.0
    f[15] = window_v / total_length if total_length > 0 else 0.0
    f[16] = frag_v / total_length if total_length > 0 else 0.0
    f[17] = padding_len / total_length if total_length > 0 else 0.0
    f[18] = (total_length * ttl_v) / window_v if window_v > 0 else 0.0
    f[19] = (total_length + ttl_v) / window_v if window_v > 0 else 0.0
    f[20] = frag_v * padding_len
    f[21] = proto_v * total_length
    f[22] = proto_v * ttl_v
    f[23] = proto_v * window_v if window_v > 0 else 0.0
    f[24] = sport_v + dport_v
    f[25] = sport_v * dport_v
    f[26] = (sport_v - dport_v) ** 2
    f[27] = ttl_v % 10
    f[28] = frag_v % 10
    f[29] = padding_len % 10
    f[30] = (int(total_length) // 100) % 10
    f[31] = (int(ttl_v) // 10) % 10
    f[32] = (int(window_v) // 100) % 10 if window_v > 0 else 0.0
    f[33] = (int(sport_v) // 100) % 10
    f[34] = (int(dport_v) // 100) % 10
    f[35] = frag_v // 10
    f[36] = padding_len // 10
    f[37] = proto_v // 10
    f[38] = total_length % 100
    f[39] = ttl_v % 100
    return f


def gen_benign(rng) -> tuple[np.ndarray, dict]:
    """Paket web normal: SYN/ACK/PUSH-ACK ke port web, TTL normal, window besar, tanpa fragmen."""
    ttl = int(rng.choice([64, 128]) + rng.normal(0, 4))
    ttl = int(np.clip(ttl, 48, 128))
    window = int(rng.integers(14600, 65536))
    sport = int(rng.integers(1024, 65536))
    dport = int(rng.choice(WEB_PORTS))
    flags = str(rng.choice(FLAG_BENIGN))
    payload = int(rng.integers(0, 65))  # payload kecil 0..64
    if flags == "S":
        payload = 0  # SYN murni tanpa payload
    ip = IP(src="10.0.0.1", dst="127.0.0.1", ttl=ttl)
    tcp = TCP(sport=sport, dport=dport, flags=flags, window=window)
    pkt = Ether() / ip / tcp
    if payload > 0:
        pkt = pkt / Raw(b"\x00" * payload)
    pkt["IP"].len = len(pkt[IP])
    return extract40(pkt), dict(kind="benign", ttl=ttl, window=window, flags=flags,
                                dport=dport, payload=payload, frag=0)


def gen_anom(rng) -> tuple[np.ndarray, dict]:
    """Paket mencurigakan: fragmentasi, TTL ekstrem, window kecil, flags R/F/FA,
    payload besar, port anomali, atau UDP dgn payload panjang."""
    kind = int(rng.integers(0, 6))
    if kind == 0:      # fragmentasi
        frag = int(rng.integers(1, 6))
        ttl = int(rng.integers(1, 256))
        window = int(rng.integers(1024, 65536))
        flags = "S"
        payload = 0
        dport = int(rng.choice(WEB_PORTS + ANOM_PORTS))
    elif kind == 1:    # TTL ekstrem
        frag = 0
        ttl = int(rng.choice([*list(range(1, 32)), *list(range(201, 256))]))
        window = int(rng.integers(1024, 65536))
        flags = "S"
        payload = 0
        dport = int(rng.choice(WEB_PORTS + ANOM_PORTS))
    elif kind == 2:    # window kecil (<8192, pola scanner)
        frag = 0
        ttl = int(rng.integers(1, 256))
        window = int(rng.integers(1024, 8191))
        flags = "S"
        payload = 0
        dport = int(rng.choice(WEB_PORTS + ANOM_PORTS))
    elif kind == 3:    # flags reset/fin (scan & teardown aneh)
        frag = 0
        ttl = int(rng.integers(1, 256))
        window = int(rng.integers(1024, 65536))
        flags = str(rng.choice(FLAG_ANOM))
        payload = int(rng.integers(0, 65))
        dport = int(rng.choice(WEB_PORTS + ANOM_PORTS))
    elif kind == 4:    # payload besar (>64, tunneling)
        frag = int(rng.integers(0, 4))
        ttl = int(rng.integers(1, 256))
        window = int(rng.integers(1024, 65536))
        flags = "PA"
        payload = int(rng.integers(65, 512))
        dport = int(rng.choice(WEB_PORTS + ANOM_PORTS))
    else:              # UDP dgn payload
        frag = 0
        ttl = int(rng.integers(1, 256))
        window = 0
        flags = ""
        payload = int(rng.integers(0, 256))
        dport = int(rng.choice(ANOM_PORTS + [53]))
        ip = IP(src="10.0.0.1", dst="127.0.0.1", ttl=ttl)
        udp = UDP(sport=int(rng.integers(1024, 65536)), dport=dport)
        pkt = Ether() / ip / udp
        if payload > 0:
            pkt = pkt / Raw(b"\x00" * payload)
        pkt["IP"].len = len(pkt[IP])
        return extract40(pkt), dict(kind="anom", ttl=ttl, window=window, flags="UDP",
                                    dport=dport, payload=payload, frag=frag)
    ip = IP(src="10.0.0.1", dst="127.0.0.1", ttl=ttl)
    if frag > 0:
        ip.flags = "MF"
        ip.frag = frag
    tcp = TCP(sport=int(rng.integers(1024, 65536)), dport=dport, flags=flags, window=window)
    pkt = Ether() / ip / tcp
    if payload > 0:
        pkt = pkt / Raw(b"\x00" * payload)
    pkt["IP"].len = len(pkt[IP])
    return extract40(pkt), dict(kind="anom", ttl=ttl, window=window, flags=flags,
                                dport=dport, payload=payload, frag=frag)


def main():
    rng = np.random.default_rng(SEED)
    t0 = time.time()
    n_ben = n_anom = N_SAMPLES // 2
    X = np.zeros((N_SAMPLES, 40), dtype=np.float32)
    y = np.zeros(N_SAMPLES, dtype=np.int8)
    meta = []
    for i in range(n_ben):
        X[i], m = gen_benign(rng)
        meta.append(m)
    for i in range(n_anom):
        X[n_ben + i], m = gen_anom(rng)
        meta.append(m)
    y[n_ben:] = 1
    print(f"Dataset: {N_SAMPLES} sampel ({n_ben} benign / {n_anom} anomali) | "
          f"RSS {psutil.Process().memory_info().rss/1e6:.0f} MB")

    from sklearn.model_selection import train_test_split
    Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=0.2, random_state=SEED, stratify=y)

    import xgboost as xgb
    model = xgb.XGBClassifier(
        n_estimators=200, max_depth=6, learning_rate=0.08, subsample=0.8,
        colsample_bytree=0.8, random_state=SEED, eval_metric="logloss",
        n_jobs=1, tree_method="hist",
    )
    model.fit(Xtr, ytr)
    print(f"Training selesai {time.time()-t0:.1f}s | RSS {psutil.Process().memory_info().rss/1e6:.0f} MB")

    # ---- AUDIT KESEHATAN ----
    nd = model.get_booster().get_dump(dump_format="json")
    import re
    n_splits = sum(len(re.findall(r'"split":', t)) for t in nd)
    print(f"\nAUDIT: n_trees={len(nd)} n_splits={n_splits} base_score={model.base_score}")
    assert n_splits > 0, "MODEL TETAP DEGENERATE (0 split) — hentikan!"

    from sklearn.metrics import accuracy_score, precision_score, recall_score, roc_auc_score
    yp = model.predict(Xte)
    pp = model.predict_proba(Xte)[:, 1]
    bs_raw = np.asarray(model.base_score).reshape(-1) if model.base_score is not None else []
    metrics = {
        "accuracy": float(accuracy_score(yte, yp)),
        "precision": float(precision_score(yte, yp)),
        "recall": float(recall_score(yte, yp)),
        "auc": float(roc_auc_score(yte, pp)),
        "n_trees": len(nd), "n_splits": n_splits,
        "base_score": float(bs_raw[0]) if len(bs_raw) else None,
    }
    print("Metrics:", json.dumps(metrics, indent=2))

    # p_ids atas 2000 paket acak (ruang lebar) — harus VARIATIF
    Xr = np.zeros((2000, 40), dtype=np.float32)
    for i in range(2000):
        if rng.random() < 0.5:
            Xr[i], _ = gen_benign(rng)
        else:
            Xr[i], _ = gen_anom(rng)
    pr = model.predict_proba(Xr)[:, 1]
    print(f"p_ids acak 2000: min={pr.min():.4f} max={pr.max():.4f} mean={pr.mean():.4f} "
          f"std={pr.std():.4f} p<0.5={(pr<0.5).sum()}/2000")
    metrics["audit_pids"] = {"min": float(pr.min()), "max": float(pr.max()),
                             "mean": float(pr.mean()), "std": float(pr.std())}

    # ---- SIMPAN ----
    MODEL_DIR.mkdir(parents=True, exist_ok=True)
    model.save_model(str(MODEL_PATH))
    feature_names = [f"feature_{i}" for i in range(40)]
    (MODEL_DIR / "feature_names.json").write_text(json.dumps(feature_names))
    # norm_params = min/max DATA LATIH (bukan 0/1) agar observasi agent bermakna
    fmin = Xtr.min(axis=0)
    fmax = Xtr.max(axis=0)
    fmax = np.where(fmax == fmin, fmin + 1, fmax)
    (MODEL_DIR / "norm_params.json").write_text(json.dumps(
        {"min": [float(v) for v in fmin], "max": [float(v) for v in fmax]}))
    (MODEL_DIR / "detector_metrics.json").write_text(json.dumps(metrics, indent=2))

    # simpan dataset (artefak reproducible)
    out = ROOT / "code" / "experiments" / "results" / "expanded_action"
    out.mkdir(parents=True, exist_ok=True)
    np.savez_compressed(out / "detector_train_data.npz", X=X, y=y)

    print(f"\nModel baru disimpan: {MODEL_PATH}")
    print(f"norm_params + feature_names + detector_metrics.json diperbarui")
    print(f"Selesai {time.time()-t0:.1f}s | RSS {psutil.Process().memory_info().rss/1e6:.0f} MB")
    del model
    gc.collect()


if __name__ == "__main__":
    main()