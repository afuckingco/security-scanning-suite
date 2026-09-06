# 🛡️ Pilgrims — Advanced Bash Orchestration Framework

> A modular Bash command center that orchestrates industry-standard security CLI tools
> (nmap, curl, whois, dig, jq, openssl, sqlite3, assetfinder, whatweb, wafw00f, and more)
> into a unified, structured reconnaissance and vulnerability-scanning pipeline.

**Pilgrims is 100% Bash.** It does not rewrite scanners — it wires mature tools together
with consistent output, reporting, and a shared core library. No Go, no Python, no database
server required (SQLite via the `sqlite3` CLI).

---

## ⚙️ What It Actually Is

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Language** | Bash 4+ | 100% shell. ~28k LOC across 119 scripts. |
| **Orchestration** | Bash sourcing + CLI tooling | `core/` = shared lib, `modules/` = per-domain scanners. |
| **Reporting** | Markdown + SQLite | `core/reporting.sh` + `core/database.sh`. |
| **Packaging** | Docker + AUR/Homebrew stubs | `Dockerfile`, `packaging/`. |
| **CI** | GitHub Actions | ShellCheck + `bash -n` + feature tests. |

---

## 📦 Modules

### Implemented (orchestrate real tools)
| Module | Tools Used | What It Does |
|--------|-----------|--------------|
| `web` | curl, dig, whois, openssl, jq, python3 | Subdomain enum, wayback OSINT, headers, SQLi/XSS/SSRF/CORS, path discovery. |
| `web-basic` | curl, dig | Lighter web recon. |
| `network` | nmap, sudo | Host discovery, port scan, service enum, vuln scripts. |
| `cloud` | aws/gcp/azure CLIs (optional) | Cloud misconfig checks. |
| `code` | semgrep/gitleaks (optional) | SAST / secret scanning. |
| `container` | trivy (optional) | Image/container scanning. |
| `email` | dig, curl | SPF/DKIM/DMARC, breach checks. |
| `iot` | nmap, curl | Embedded device recon. |
| `my-plugin` | template | User scaffold for custom modules. |
| `custom-module` | template + plugins | Custom checks (header_check plugin included). |

### Simulated / Educational (print banners + write sample reports — **no live exploitation**)
These exist as scaffolding to demonstrate the framework's structure and are clearly marked
`SIMULATION STUB` at the top of each file:
`ad`, `ai`, `binary`, `blockchain`, `financial`, `forensic`, `ics`, `medical`, `mobile`,
`redteam`, `wireless`, plus `core/{aiml,cloudnative,compliance,crypto,devsecops,forensics,hardware,malware,protocol,supplychain,threatintel}`, `core/{formal,symbolic,mutation}` etc.

> Use the simulated modules for learning the framework's shape, not for real assessments.

---

## 🚀 Quick Start

```bash
# 1. Clone
git clone https://github.com/afuckingco/pilgrims.git
cd pilgrims

# 2. Install dependencies (Debian/Ubuntu/Kali/WSL2)
sudo apt update && sudo apt install -y \
  nmap curl whois dnsutils jq openssl python3 sqlite3 \
  qrencode netcat-openbsd bc file binutils xxd uuid-runtime

# Optional scanners (used by some modules if present):
sudo apt install -y assetfinder ffuf whatweb wafw00f trivy

# 3. Make scripts executable
chmod +x pilgrims.sh core/*.sh modules/*/pilgrims-*.sh

# 4. Run it
./pilgrims.sh --help
./pilgrims.sh --module=web https://example.com
./pilgrims.sh --interactive
```

> **⚠️ Warning:** Use only on systems you own or have explicit, written authorization to test.

---

## 🏗️ Architecture

```
pilgrims.sh              # entry point — sources core/ + dispatches module
core/
  strict.sh              # set -euo pipefail + fail-fast traps (sourced first)
  ui.sh utils.sh logging.sh database.sh reporting.sh
  stealth_profiles.sh scan_templates.sh themes.sh crypto.sh
  recorder.sh profiler.sh qr_generator.sh
  <domain>.sh            # simulated/educational modules (marked SIMULATION STUB)
modules/<name>/pilgrims-<name>.sh   # each is self-contained + has a source guard
tests/unit/              # bashunit-style tests (source guards, modules, main)
shared/core/             # historical mirror of core/ — do not edit directly
```

**Module contract:**
```bash
MODULE_NAME="web"
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$MODULE_DIR/../.." && pwd)"
source "$SCRIPT_DIR/core/ui.sh"
source "$SCRIPT_DIR/core/utils.sh"
# Guard: never execute when sourced
[[ "${BASH_SOURCE[0]}" = "$0" ]] || { echo "Do not source this module" >&2; return 0 2>/dev/null || exit 0; }
TARGET="$1"; shift
```

---

## 🧪 Testing

```bash
./test-simple.sh          # fast smoke test
./test-all-features.sh    # full feature test
./full-test.sh            # exhaustive
tests/unit/run_all.sh     # unit suite (source guards, modules, main dispatch)
```

CI runs ShellCheck (with project `.shellcheckrc`) + `bash -n` on every push/PR.

---

## 📂 Documentation

- `INSTALLATION.md` — full install steps (manual, Docker, WSL2)
- `MODULES.md` — module reference
- `COMMANDS.md` — CLI flags
- `USER_GUIDE.md` / `EXAMPLES.md` — usage walkthroughs
- `API_REFERENCE.md` — core function reference
- `SECURITY.md` — vulnerability reporting policy
- `DISCLAIMER.md` — legal / authorized-use notice

---

## 🛡️ Security Notes

- `core/strict.sh` enables `set -euo pipefail` with an error trap on all entry scripts.
- Report encryption (`core/crypto.sh`) uses `openssl aes-256-cbc -pbkdf2 -iter 100000`
  and reads the passphrase from stdin (not the process table).
- No API keys are required; all tooling is local CLI.
- Logs go to `shared/logs/`; scan history to `shared/db/pilgrims.db` (SQLite).

---

## 📈 Status & Roadmap

**Status:** Active — core orchestration + web/network modules are production-useful.
Simulated modules are scaffolding and should be expanded or removed per your needs.

Roadmap:
- [ ] Promote selected simulated modules to real implementations.
- [ ] Add a module manifest (replace filesystem glob discovery).
- [ ] Cross-module data passing (e.g. subdomains → network scan).

---

## 👤 Author

**afuckingco** — Security researcher, tooling developer.
GitHub: [@afuckingco](https://github.com/afuckingco)

> *Security is not a product, but a process. Pilgrims is the automation of that process.*

MIT License.
