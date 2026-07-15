# Secure CI Pipeline

A **fully automated CI/CD security scanning pipeline** for multi‑stack projects (Node/JavaScript, Python, generic source code, and network traffic). The workflow runs on every push to `main` and on every pull‑request, producing a comprehensive Markdown report and optional Slack notification.

---

## Features

- **Dependency vulnerability scans**
  - `npm audit` → detects known issues in `package.json` dependencies.
  - `pip-audit` → checks PyPI packages from `requirements.txt`.
- **Secrets detection** with **Gitleaks** (binary bundled, no external install required).
- **Network‑level IDS** using **Suricata** inside Docker – validates that containers do not expose vulnerable traffic patterns.
- **Aggregated report** (`security_report.md`) includes JSON snippets for quick triage.
- **GitHub Actions** integration – zero‑config for most repositories.
- **Slack webhook** support (store token in `SLACK_WEBHOOK` secret).
- **Artifacts** – the report is uploaded as a build artifact for archival.

---

## Quick start (local test)
```bash
# Clone the repository
git clone https://github.com/afuckingco/secure-ci-pipeline.git
cd secure-ci-pipeline

# Install Python dependencies (pip‑audit) – Node deps are optional for a local test
pip install -r requirements.txt

# Run the individual scan scripts
./scripts/run_pip_audit.sh        # → pip_audit.json
./scripts/run_gitleaks.sh        # → gitleaks.json (binary bundled)
# Docker must be running for Suricata
./scripts/run_suricata.sh        # → suricata/log/evts.json

# Combine everything into a single report
./scripts/aggregate_report.py
cat security_report.md
```
> **Note:** `npm audit` requires a `package-lock.json`. The repository already ships one; if you add dependencies, run `npm i --package-lock-only` and commit the updated lockfile.

---

## GitHub Actions workflow
The pipeline is defined in `.github/workflows/security-scan.yml`. It automatically:
1. Checks out the code.
2. Sets up Node 20 & Python 3.11.
3. Installs the required dependencies.
4. Executes the four scan scripts.
5. Aggregates the results.
6. Uploads the markdown as an artifact.
7. (Optional) Sends a formatted Slack message.

---

## Configuration
| Item | Description | Default |
|------|-------------|---------|
| `SLACK_WEBHOOK` (secret) | Slack incoming webhook URL for notifications. | *Not set* (skip notification) |
| Suricata Docker image | Uses `jasonish/suricata:latest`. Override by editing `scripts/run_suricata.sh`. |
| Gitleaks binary | Bundled at `bin/gitleaks.exe`. Replace with a newer version if desired. |

---

## Release history
### v1.0.0 – 2026‑07‑12
- Initial release of **Secure CI Pipeline**.
- Includes all scan scripts, Docker‑based Suricata, bundled Gitleaks binary, and GitHub Actions workflow.
- Added professional README, `.gitignore`, and CI documentation.

---

## License
MIT © 2026 afuckingco — free for personal and commercial use.
