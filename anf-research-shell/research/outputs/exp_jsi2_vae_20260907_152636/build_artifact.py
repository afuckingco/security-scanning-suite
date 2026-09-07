#!/usr/bin/env python3
"""Build CSV ringkas deliverable JSI2 (VAE validation) untuk sitasi.

Input : research/outputs/jsi2_vae_exp.json (hasil run.sh / script asli).
Output: research/outputs/jsi2_vae_metrics.csv (metrik,value per baris).
Catatan: JSON eksperimen (jsi2_vae_exp.json) & gambar (jsi2_vae_loss.png)
sudah diproduksi langsung oleh run_vae_experiment.py — CSV ini hanya tabel
ringkas untuk sitasi (analog dca_sweep_mc.csv / mini_soc_detector_metrics.csv).
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT_DIR = ROOT / "research" / "outputs"
SRC = Path(sys.argv[1]) if len(sys.argv) > 1 else OUT_DIR / "jsi2_vae_exp.json"


def main() -> int:
    m = json.loads(SRC.read_text())
    rows = [
        ("elbo_final", m["elbo_final"]),
        ("recon_mse_final", m["recon_mse_final"]),
        ("kl_final", m["kl_final"]),
        ("wasserstein2_approx", m["wasserstein2_approx"]),
    ]
    csv = OUT_DIR / "jsi2_vae_metrics.csv"
    csv.write_text("metric,value\n" + "".join(f"{k},{v:.4f}\n" for k, v in rows))
    print(f"artefak: {csv.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())