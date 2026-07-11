# sec-scan CLI

**sec-scan** is a lightweight command‑line wrapper that bundles the most common security‑scanning tools (npm audit, pip‑audit, Gitleaks, Suricata) into a single, developer‑friendly entry point.

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
# Clone the repository
git clone https://github.com/afuckingco/sec-scan-cli.git
cd sec-scan-cli

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
The command returns the raw output (truncated to ~~200 characters) and a success/failure status.

### Version
```bash
sec-scan version
```
Shows the current CLI version.

---

## Development notes
- The scripts are located in `scripts/` and are executed via `subprocess`.  They are simple wrappers around the original implementations used in the *secure‑ci‑pipeline* project.
- The `bin/` directory contains the pre‑compiled Gitleaks binary for Windows.  It is excluded from the final package via `.gitignore`.
- To add more scanners, extend `run_script` in `src/sec_scan/cli.py` and add a corresponding shell script under `scripts/`.

---

## License
MIT © 2026 Afiq Andico
