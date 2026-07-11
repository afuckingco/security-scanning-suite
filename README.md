# Secure CI Pipeline

Automated security scanning for JavaScript/TypeScript, Python, and generic code bases.

## What it does
- **npm audit** – checks Node dependencies for known vulnerabilities.
- **pip‑audit** – checks Python dependencies.
- **gitleaks** – secrets scanning across the repository.
- **Suricata (Docker)** – network‑intrusion‑detection simulation on the build image.
- **Aggregated report** – markdown + JSON artefact posted to CI and optional Slack webhook.

## Quick start
```bash
# clone the repo (or create a new one with the generated files)
git init secure-ci-pipeline && cd secure-ci-pipeline
# copy generated files (already present in this folder)
# install dependencies for local testing
npm ci
pip install -r requirements.txt
# run one scan locally (optional)
./scripts/run_npm_audit.sh && ./scripts/run_pip_audit.sh && ./scripts/run_gitleaks.sh && ./scripts/run_suricata.sh && ./scripts/aggregate_report.py
```

Push to GitHub and enable the **Security Scan** workflow under `.github/workflows/security-scan.yml`.
