#!/usr/bin/env bash
# Reproduksi eksperimen validasi empiris JSI2 (VAE pada campuran 6 Gaussian 2D).
# Salinan script asli project "Adversarial ML for IDS Validation via Red-Team
# Techniques" code/scripts/run_vae_experiment.py — TIDAK dimodifikasi (lihat sha
# di reproducibility_manifest.md). Deterministik SEED=42 (hardcoded di script).
# 120 epoch, Adam lr=1e-3, batch 256; metrik: ELBO/(-ELBO), recon MSE, KL, W2.
# Dependensi: pip install -r requirements.txt (torch/numpy/matplotlib).
#
# Script menulis ke path RELATIF-cwd (research/outputs/... dan
# submissions/jsi2/figures/...), jadi dijalankan di SANDBOX tmp agar TIDAK
# menulis ke repo mana pun; hasil disalin ke research/outputs/ ANF:
#   - research/outputs/jsi2_vae_exp.json   (metrik, identik format asli)
#   - research/outputs/jsi2_vae_loss.png   (fig: kurva objektif + data vs sampel)
# Sandbox dihapus otomatis (trap EXIT). Verifikasi hash ada di make verify.
set -euo pipefail

# Resolve absolut (aman dipanggil dari mana pun)
SELF="$(readlink -f "$0")"
SRC_DIR="$(dirname "$SELF")"
ROOT="$(cd "$SRC_DIR/../../.." && pwd)"

# Resolusi interpreter: $PYTHON dulu, lalu kandidat lokal; kartu deps torch+numpy+matplotlib.
resolve_py() {
    local c
    for c in "${PYTHON:-}" \
        "$ROOT/.venv/bin/python" \
        "$HOME/venv/bin/python" \
        python3; do
        [ -n "$c" ] || continue
        if "$c" -c "import torch, numpy, matplotlib" >/dev/null 2>&1; then
            echo "$c"; return 0
        fi
    done
    return 1
}
PY="$(resolve_py)" || {
    echo "Tidak ada interpreter dengan torch+numpy+matplotlib." >&2
    echo "Buat venv lalu: pip install -r $SRC_DIR/requirements.txt" >&2
    exit 2
}

SB="$(mktemp -d /tmp/hermes-verify-jsi2vae-XXXXXX)"
trap 'rm -rf "$SB"' EXIT
mkdir -p "$SB/research/outputs" "$SB/submissions/jsi2/figures"
( cd "$SB" && "$PY" "$SRC_DIR/run_vae_experiment.py" )
cp "$SB/research/outputs/jsi2_vae_exp.json" "$ROOT/research/outputs/jsi2_vae_exp.json"
cp "$SB/submissions/jsi2/figures/fig2_vae_loss.png" "$ROOT/research/outputs/jsi2_vae_loss.png"
echo "artefak -> $ROOT/research/outputs/jsi2_vae_exp.json + jsi2_vae_loss.png"