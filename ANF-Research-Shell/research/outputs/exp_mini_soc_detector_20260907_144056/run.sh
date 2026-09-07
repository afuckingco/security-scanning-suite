#!/usr/bin/env bash
# Reproduksi eksperimen detektor ML mini-SOC (JSI1, arsitektur 8 layanan).
# Salinan script asli project "Adversarial ML for IDS Validation via Red-Team
# Techniques" code/mini-soc-enterprise-arch/ml_detector/train_detector_real.py —
# TIDAK dimodifikasi (lihat sha di reproducibility_manifest.md). Deterministik
# SEED=42 (hardcoded di script). 12.000 sampel sintetis (6.000 benign /
# 6.000 anomali) dari aturan domain paket; XGBoost n_estimators=200, seed 42.
# Dependensi: pip install -r requirements.txt (numpy/xgboost/psutil/scapy).
# CATATAN: script asli menulis model + detector_metrics.json ke ROOT yang
# di-anchor ke lokasi file (Path(__file__).parents[3]) — dijalankan dari salinan
# scaffold ini berarti menulis ke repo ANF. Untuk verifikasi TANPA polusi pakai:
#   make verify   (scripts/verify_repro.sh — sandbox tmp, cek hash vs manifest)
# Output artefak: research/outputs/mini_soc_detector_metrics.{json,csv,png}
#   (dibuat dari detector_metrics.json regenerasi — lihat build_artifact.py).
set -euo pipefail
cd "$(dirname "$0")/../../.."          # root repo ANF

# Resolusi interpreter: $PYTHON dulu, lalu kandidat lokal dengan kartu
# deps numpy+xgboost+psutil+scapy (kegagalan = panduan install).
resolve_py() {
    local c
    for c in "${PYTHON:-}" \
        "$(pwd)/.venv/bin/python" \
        "$HOME/venv/bin/python" \
        python3; do
        [ -n "$c" ] || continue
        if "$c" -c "import numpy, xgboost, psutil, scapy" >/dev/null 2>&1; then
            echo "$c"; return 0
        fi
    done
    return 1
}
PY="$(resolve_py)" || {
    echo "Tidak ada interpreter dengan numpy+xgboost+psutil+scapy." >&2
    echo "Buat venv lalu: pip install -r $(dirname "$0")/requirements.txt" >&2
    exit 2
}
"$PY" "$(dirname "$0")/train_detector_real.py"