#!/usr/bin/env bash
# Reproduksi eksperimen DCA sweep alpha/m (bukti H5, eksperimen JSI3 no.3).
# Salinan script asli project "Adversarial ML for IDS Validation via Red-Team
# Techniques" code/scripts/dca_sweep_demo.py — TIDAK dimodifikasi (lihat sha di
# reproducibility_manifest.md). Deterministik SEED=42 (hardcoded di script).
# Output: research/outputs/dca_sweep_mc.{json,png} relatif cwd repo ANF.
set -euo pipefail
cd "$(dirname "$0")/../../.."          # root repo ANF
PY="${PYTHON:-$HOME/venv/bin/python}"
"$PY" "$(dirname "$0")/dca_sweep_demo.py"
