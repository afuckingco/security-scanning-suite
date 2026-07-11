#!/usr/bin/env bash
set -euo pipefail
python -m pip install -r requirements.txt
pip-audit -r requirements.txt --format json > pip_audit.json
