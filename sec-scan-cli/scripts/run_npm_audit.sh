#!/usr/bin/env bash
set -euo pipefail
npm ci
npm audit --json > npm_audit.json
