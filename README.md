# Secure Ops Suite

A **single, cohesive platform** that combines two powerful security capabilities:

1. **Anomaly‑Detection Log Analyzer** – a Python + PyTorch‑Lightning service that ingests logs (Suricata, CI, application) and flags abnormal patterns using unsupervised models (IsolationForest, AutoEncoder).  Outputs a concise `anomaly_report.md` ready for Slack or GitHub‑Actions.
2. **Secure Package Registry Proxy** – an Express/Node.js proxy for npm & PyPI.  Every requested package is scanned with:
   - `npm audit` / `pip‑audit`
   - **Gitleaks** (secrets detection, bundled binary)
   - optional static analysis (ESLint, Bandit)
   Packages failing policy are blocked and a Slack alert is sent.

Both components share a **common Docker‑Compose orchestration**, making the suite easy to spin‑up on any CI/CD runner or on‑prem server.

---

## Architecture Overview
```
+--------------------+       +-------------------+       +------------------+
|  Package Registry  | <---> |  Registry Proxy   | <---> |   External npm /  |
|   (npm / PyPI)     |       |  (Node.js/Express)|       |   PyPI registry   |
+--------------------+       +-------------------+       +------------------+
        |                               |
        v                               v
+--------------------+       +-------------------+
|  Anomaly Analyzer  | <---> |   Log Collector   |
|  (Python/ML)       |       | (Suricata, CI)    |
+--------------------+       +-------------------+
```

- **Log Collector** runs the existing `secure-ci-pipeline` scripts, storing logs under `logs/`.
- **Anomaly Analyzer** watches `logs/` (via `watchdog`), processes new files, and writes `anomaly_report.md`.
- **Registry Proxy** intercepts package requests, runs the same security scripts (`npm audit`, `pip‑audit`, `gitleaks`), then forwards clean packages.

---

## Quick‑Start (Docker‑Compose)
```bash
# Clone & cd
git clone https://github.com/afuckingco/secure-ops-suite.git
cd secure-ops-suite

# Build & start all services
docker compose up --build -d
```
The compose file spins up:
- `proxy` (Node.js on port **8080**) – set your npm/pypi client to use `http://localhost:8080`.
- `analyzer` (Python, port **8000**) – expose REST endpoint `/detect`.
- `log_collector` (runs existing security‑scan scripts) – populates `logs/`.

### Configure your package manager
```bash
# npm example
npm set registry http://localhost:8080

# pip example (using pip.conf)
cat <<EOF > ~/.config/pip/pip.conf
[global]
index-url = http://localhost:8080/simple
EOF
```
Now any `npm install` or `pip install` will be routed through the proxy and automatically scanned.

---

## Development
- **Python services** live in `src/` (FastAPI for the analyzer, watchdog for file monitoring).
- **Node proxy** lives in `dashboard/` (Express server + simple React UI for dashboard).
- **Dockerfile** for each component is provided under `docker/`.
- Run unit tests with `pytest -n auto` (parallel) and `npm test` for the proxy.

---

## License
MIT © 2026 Afiq Andico
