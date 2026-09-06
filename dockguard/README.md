# 🛡️ dockguard — Dockerfile security linter & analyzer

**Static analysis for Dockerfiles — finds security issues, anti-patterns, and best-practice violations.**
No daemon required, no images pulled, runs in milliseconds.

[![Python](https://img.shields.io/badge/Python-3.8%2B-blue)]()
[![License](https://img.shields.io/badge/license-MIT-blue)]()
[![Tests](https://img.shields.io/badge/tests-30%2B%20passed-success)]()
[![No deps](https://img.shields.io/badge/dependencies-zero-success)]()

---

## ✨ Features

- 🔒 **Security rules** — secrets in ENV, curl|sh, root user, `:latest` tags
- 📦 **Best practices** — apt-get cleanup, COPY vs ADD, version pinning, HEALTHCHECK
- ⚡ **Zero dependencies** — pure Python stdlib (no pip install required)
- 🎯 **3 output formats** — pretty terminal, JSON, GitHub Actions annotations
- ⚙️ **Configurable** — `.dockguard.yml` to ignore rules or severities
- 🚦 **CI-friendly exit codes** — `0=clean`, `1=warnings`, `2=errors`
- 🧪 **30+ tests** covering parser, rules, reporter

---

## 🚀 Quick Start

### Install

```bash
git clone https://github.com/afiqandico13/dockguard.git
cd dockguard
# No dependencies to install — uses Python stdlib only
```

### Usage

```bash
# Scan current directory's Dockerfile
python -m dockguard

# Scan specific file
python -m dockguard path/to/Dockerfile

# JSON output
python -m dockguard --format json Dockerfile > report.json

# GitHub Actions annotation
python -m dockguard --format github Dockerfile

# Ignore specific rules
python -m dockguard --ignore DG001,DG004 Dockerfile

# Quiet mode (only exit code)
python -m dockguard --quiet Dockerfile && echo "clean"
```

### Exit Codes

| Code | Meaning |
|:---:|---|
| `0` | No issues found (or only info) |
| `1` | Warnings present |
| `2` | Errors found (CI should fail) |

---

## 📋 Rules

| ID | Severity | Description |
|:---|:---:|:---|
| DG001 | warning | Container runs as root (no USER or USER root) |
| DG002 | info | ADD used for local files (prefer COPY) |
| DG003 | **error** | Possible hardcoded secret in ENV / ARG |
| DG004 | warning | Image uses `:latest` tag (non-deterministic) |
| DG005 | warning | `apt-get install` without cleanup (bloats image) |
| DG006 | **error** | Piping `curl`/`wget` output to shell (insecure) |
| DG007 | info | No HEALTHCHECK instruction defined |
| DG008 | info | pip/npm package not pinned to specific version |
| DG009 | info | > 10 RUN instructions (combine or use multi-stage) |
| DG010 | info | Build tools without multi-stage build (bloated image) |

Add new rules easily — see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## ⚙️ Configuration

Create `.dockguard.yml` in your repo root:

```yaml
# Rules to ignore (comma-separated)
ignore-rules: DG002, DG008

# Severities to ignore
ignore-severity: info

# Run only specific rules (default: all)
enabled-rules: DG001, DG003, DG006
```

CLI flags override config file settings.

---

## 📊 Output Formats

### Pretty (default)

```
  dockguard scan: Dockerfile
  ──────────────────────────────────────────────────────────────

  ✗ ERROR (1)
    [DG003] Possible hardcoded secret: 'password' in ENV
      @ line 12
      → Use Docker secrets, env files, or runtime injection

  ⚠ WARNING (2)
    [DG001] No USER instruction — container will run as root by default
      @ line 1
      → Add 'USER <non-root-user>' near the end of the Dockerfile

  ──────────────────────────────────────────────────────────────
  Total: 1 error(s), 2 warning(s)
```

### JSON

```json
{
  "tool": "dockguard",
  "version": "1.0.0",
  "file": "Dockerfile",
  "findings": [
    {"rule_id": "DG003", "severity": "error", "message": "...", "line": 12}
  ],
  "summary": {"error": 1, "warning": 2, "info": 0}
}
```

### GitHub Actions

```
::error file=Dockerfile,line=12::DG003: Possible hardcoded secret: 'password' in ENV
::warning file=Dockerfile,line=1::DG001: No USER instruction
```

Renders as inline annotations in PRs.

---

## 🧪 Example

Given this Dockerfile:

```dockerfile
FROM node:latest
WORKDIR /app
COPY package.json .
RUN apt-get install -y curl
RUN curl https://get.example.com | sh
ENV API_KEY=sk-abc123secret
EXPOSE 3000
```

Run `python -m dockguard Dockerfile`:

```
  ✗ ERROR (2)
    [DG003] Possible hardcoded secret: 'key' in ENV
    [DG006] Piping curl output to sh — insecure (unverified code execution)

  ⚠ WARNING (2)
    [DG001] No USER instruction — container will run as root
    [DG004] Image uses ':latest' tag: node
    [DG005] apt-get install without cleaning apt cache (bloats image)

  ℹ INFO (2)
    [DG007] No HEALTHCHECK instruction defined
    [DG008] npm package not pinned to specific version
```

---

## 🛠️ Development

```bash
# Run tests
python -m unittest discover tests -v

# Run from source (no install needed)
python -m dockguard path/to/Dockerfile

# Project structure
dockguard/
├── __init__.py
├── __main__.py        # CLI entry point
├── parser.py          # Dockerfile parser
├── rules.py           # 10 lint rules
└── reporter.py        # output formatters
tests/
├── test_parser.py
├── test_rules.py
└── test_reporter.py
```

---

## 🤝 Why dockguard?

| Tool | Pros | Cons |
|---|---|---|
| **hadolint** | Industry standard, mature | Bash + Go, complex install |
| **trivy** | CVE scanning | Needs Docker daemon, heavy |
| **dockerfile-utils** | Quick checks | Limited rules |
| **dockguard** ✅ | Zero deps, fast, security focus | Newer (1.0) |

Use **dockguard** for:
- Fast feedback in dev (no daemon, no install)
- CI/CD gates (exit codes + GitHub annotations)
- Security audit (no network — runs offline)
- Lightweight validation in pre-commit hooks

Pair with **hadolint** for comprehensive Dockerfile linting, and **trivy** for image CVE scanning.

---

## 📜 License

MIT © 2026 Afiq Andico Pangimpian

## 🔗 Related Projects

- [pilgrims](https://github.com/afiqandico13/pilgrims) — Bash web security scanner
- [link-cleaner](https://github.com/afiqandico13/link-cleaner) — Privacy browser extension
- [tokokita](https://github.com/afiqandico13/tokokita) — Security-hardened Node.js shop
- [kopikita](https://github.com/afiqandico13/kopikita) — ML cafe analytics