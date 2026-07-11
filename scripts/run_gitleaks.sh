#!/usr/bin/env bash
set -euo pipefail
gitleaks detect -c .gitleaks.toml -r . -f json > gitleaks.json