# sec-scan CLI

**sec-scan** is a lightweight command‑line wrapper that bundles the most common security‑scanning tools (npm audit, pip‑audit, Gitleaks, Suricata) into a single, developer‑friendly entry point — plus the CI/CD pipeline that runs them automatically.

> Konsolidasi 2026‑09‑07: project ini menggabungkan `sec-scan-cli` (CLI) dan `secure-ci-pipeline` (pipeline CI/CD) — keduanya sebelumnya berbagi script scanner yang identik.

It ships the required scripts and a bundled Gitleaks binary, so a developer only needs to `pip install sec-scan` (or install from source) and can run:

```bash
sec-scan run          # Execute full pipeline (npm, pip, gitleaks, Suricata)
sec-scan single npm   # Run only npm audit
sec-scan single pip   # Run only pip‑audit
sec-scan single gitleaks
sec-scan single suricata
```

The tool produces a `security_report.md` file with a concise summary of all findings, ready to be uploaded as a CI artifact or inspected locally.

---

## Installation (from source)
```bash
# Clone the monorepo, lalu masuk ke komponen ini
git clone https://github.com/afiqandico/security-lab.git
cd security-lab/sec-scan-cli

# Install in editable mode (development)
python -m pip install -e .
```

The installation pulls the runtime dependencies defined in `pyproject.toml`:
- `click` – command line interface builder.
- `requests` – for potential future webhooks.
- `pyyaml` – for configuration files (optional).
- `rich` – pretty terminal output.

## Usage
### Full pipeline
```bash
sec-scan run
```
Runs, in order:
1. **npm audit** – requires a `package-lock.json` in the working directory.
2. **pip‑audit** – reads `requirements.txt`.
3. **Gitleaks** – scans the repository for secrets using the bundled binary.
4. **Suricata** – launches a Docker container to perform IDS analysis on network traffic (Docker must be running).
5. Aggregates all outputs into `security_report.md`.

### Single tool
```bash
sec-scan single npm      # Only npm audit
sec-scan single pip      # Only pip‑audit
sec-scan single gitleaks # Only secret scan
sec-scan single suricata# Only Suricata IDS run
```
The command returns the raw output (truncated to ~200 characters) and a success/failure status.

### Version
```bash
sec-scan version
```
Shows the current CLI version.

---

## Mode pipeline (CI/CD)

Workflow: `.github/workflows/sec-scan-cli-security-scan.yml` (berjalan saat `sec-scan-cli/**` berubah). Alur:
1. Set up Node 20 & Python 3.11.
2. Install deps: `npm ci` (dari `package-lock.json`) + `pip install -r requirements.txt` (= `pip-audit`).
3. Jalankan 4 script scan: `run_npm_audit.sh`, `run_pip_audit.sh`, `run_gitleaks.sh`, `run_suricata.sh` (Suricata dinonaktifkan di GitHub-hosted runner).
4. `aggregate_report.py` → `security_report.md`.
5. Upload artifact + (opsional) kirim Slack via secret `SLACK_WEBHOOK`.

Jalankan manual:
```bash
pip install -r requirements.txt
./scripts/run_pip_audit.sh        # → pip_audit.json
./scripts/run_gitleaks.sh        # → gitleaks.json (binary bundled)
./scripts/aggregate_report.py
cat security_report.md
```
> **Note:** `npm audit` memerlukan `package-lock.json` (sudah disertakan; update dengan `npm i --package-lock-only` bila menambah dependensi).

---

## Development notes
- The scripts are located in `scripts/` and are executed via `subprocess`.
- The `bin/` directory contains the pre‑compiled Gitleaks binary for Windows. It is excluded from the final package via `.gitignore`.
- To add more scanners, extend `run_script` in `src/sec_scan/cli.py` and add a corresponding shell script under `scripts/`.

---

## License
MIT © 2026 Afiq Andico Pangimpian
