#!/usr/bin/env python3
"""Build artefak reproducibility JSI1 (mini-SOC ML detector) dari detector_metrics.json.

Input : detector_metrics.json hasil train_detector_real.py (deterministik, seed 42;
        lokasi default: proyek Adversarial ML, code/mini-soc-enterprise-arch/ml_detector/).
Output: research/outputs/mini_soc_detector_metrics.{json,csv,png}
        - json: salinan metrik + provenance
        - csv : satu baris metrik ringkas utk sitasi (analog dca_sweep_mc.csv)
        - png : bar chart 4 metrik (akurasi/presisi/recall/AUC) skala 0..1

Catatan: file .json/.csv/.png ikut .gitignore ANF — hanya manifest yang di-track.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

ROOT = Path(__file__).resolve().parents[3]
OUT_DIR = ROOT / "research" / "outputs"


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: build_artifact.py <path/detector_metrics.json>", file=sys.stderr)
        print("(make verify meneruskan path hasil regenerasi sandbox; jalur ini"
              " sengaja TIDAK punya default agar repo berdiri sendiri)", file=sys.stderr)
        return 2
    src = Path(sys.argv[1])
    if not src.is_file():
        print(f"file tidak ditemukan: {src}", file=sys.stderr)
        return 2
    m = json.loads(src.read_text())

    # 1) JSON artefak: metrik + provenance (bukan hanya salinan)
    artifact = {
        "experiment": "mini_soc_ml_detector",
        "source_script": "code/mini-soc-enterprise-arch/ml_detector/train_detector_real.py",
        "seed": 42,
        "n_samples": 12000,
        "n_features": 40,
        "metric": {k: m[k] for k in ("accuracy", "precision", "recall", "auc")},
        "model": {"n_trees": m["n_trees"], "n_splits": m["n_splits"]},
    }
    json_path = OUT_DIR / "mini_soc_detector_metrics.json"
    json_path.write_text(json.dumps(artifact, indent=2))

    # 2) CSV ringkas satu baris
    csv_path = OUT_DIR / "mini_soc_detector_metrics.csv"
    csv_path.write_text(
        "metric,value\n"
        f"accuracy,{m['accuracy']:.6f}\n"
        f"precision,{m['precision']:.6f}\n"
        f"recall,{m['recall']:.6f}\n"
        f"auc,{m['auc']:.6f}\n"
    )

    # 3) PNG: bar chart 4 metrik
    names = ["Accuracy", "Precision", "Recall", "AUC"]
    vals = [m["accuracy"], m["precision"], m["recall"], m["auc"]]
    fig, ax = plt.subplots(figsize=(7, 4.5), dpi=150)
    bars = ax.bar(names, vals, color=["#4C72B0", "#DD8452", "#55A868", "#C44E52"])
    ax.set_ylim(0.98, 1.001)
    ax.set_ylabel("Score")
    ax.set_title("Mini-SOC ML Detector — Holdout Metrics (seed 42, 12,000 samples)")
    for bar, v in zip(bars, vals):
        ax.text(bar.get_x() + bar.get_width() / 2, v + 0.0002, f"{v:.4f}",
                ha="center", va="bottom", fontsize=9)
    fig.tight_layout()
    png_path = OUT_DIR / "mini_soc_detector_metrics.png"
    fig.savefig(png_path)
    plt.close(fig)

    print(f"artefak: {json_path.name} / {csv_path.name} / {png_path.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())