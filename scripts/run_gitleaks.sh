#!/usr/bin/env bash
set -euo pipefail
# Use bundled gitleaks binary if present, otherwise fall back to PATH
if [[ -x "$(dirname "$0")/../bin/gitleaks.exe" ]]; then
  GL="$(dirname "$0")/../bin/gitleaks.exe"
else
  GL=gitleaks
fi
$GL detect -c "$(dirname "$0")/../.gitleaks.toml" -r . -f json > "$(dirname "$0")/../gitleaks.json"
