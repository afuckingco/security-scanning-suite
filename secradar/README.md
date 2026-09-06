# 🔒 secradar — fast secret scanner

**Find API keys, tokens, passwords, and high-entropy secrets in source code.**
100% local, zero network calls, written in Rust for speed.

[![Rust](https://img.shields.io/badge/rust-1.96%2B-orange)]()
[![License](https://img.shields.io/badge/license-MIT-blue)]()
[![Tests](https://img.shields.io/badge/tests-10%20passed-success)]()
[![Performance](https://img.shields.io/badge/build-LTO%20optimized-success)]()

---

## ✨ Features

- 🚀 **Fast** — Rust release build with LTO, parallel scanning via rayon
- 🎯 **30+ rules** — AWS, GitHub, Slack, Stripe, JWT, RSA keys, generic patterns
- 📊 **Entropy-based detection** — find unknown secrets via Shannon entropy
- 🔍 **Git history scanning** — find secrets in past commits (`--git-history`)
- 🎨 **4 output formats** — pretty terminal, JSON, SARIF (GitHub code scanning), compact
- ⚙️ **Configurable** — `.secradar.toml` for custom rules/allowlist
- 🪶 **Zero dependencies on your code** — pure binary, no scripts
- 🔒 **Privacy-first** — all processing local, nothing leaves your machine

---

## 🚀 Quick Start

### Install

```bash
git clone https://github.com/afiqandico13/secradar.git
cd secradar
cargo build --release
./target/release/secradar --help
```

### Usage

```bash
# Scan current directory
./target/release/secradar

# Scan specific path
./target/release/secradar /path/to/project

# JSON output
./target/release/secradar --format json > report.json

# SARIF for GitHub Code Scanning
./target/release/secradar --format sarif > secradar.sarif

# Scan git history (last 100 commits)
./target/release/secradar --git-history --max-commits 100

# Skip noisy rules
./target/release/secradar --skip-rule SR031,SR062

# Only show high/critical severity
./target/release/secradar --min-severity high

# CI mode: only exit code
./target/release/secradar --quiet --no-fail
```

### Exit codes

| Code | Meaning |
|:---:|---|
| `0` | No secrets found |
| `1` | Secrets found (CI should fail) |
| `2` | Parse error or file not found |

---

## 📋 Rules

### Cloud providers

| ID | Severity | Detects |
|:---|:---:|:---|
| SR001 | 🔴 Critical | AWS Access Key ID |
| SR002 | 🔴 Critical | AWS Secret Access Key |
| SR003 | 🔴 Critical | Google API Key |
| SR004 | 🟠 High | Azure Subscription Key |
| SR005 | 🟠 High | DigitalOcean PAT |

### Source control

| ID | Severity | Detects |
|:---|:---:|:---|
| SR010 | 🔴 Critical | GitHub Personal Access Token |
| SR011 | 🔴 Critical | GitHub Fine-grained PAT |
| SR012 | 🔴 Critical | GitHub OAuth Token |
| SR013 | 🔴 Critical | GitLab PAT |

### Communication

| ID | Severity | Detects |
|:---|:---:|:---|
| SR020 | 🟠 High | Slack Bot Token |
| SR021 | 🟡 Medium | Slack Webhook URL |
| SR022 | 🟡 Medium | Discord Webhook URL |
| SR023 | 🟠 High | Telegram Bot Token |

### Payment

| ID | Severity | Detects |
|:---|:---:|:---|
| SR030 | 🔴 Critical | Stripe Live Key |
| SR031 | 🔵 Low | Stripe Test Key |

### Auth tokens

| ID | Severity | Detects |
|:---|:---:|:---|
| SR040 | 🟡 Medium | JWT Token |
| SR041 | 🟠 High | Heroku API Key |
| SR042 | 🟠 High | npm Auth Token |
| SR043 | 🟠 High | PyPI Token |

### Private keys

| ID | Severity | Detects |
|:---|:---:|:---|
| SR050 | 🔴 Critical | RSA Private Key |
| SR051 | 🔴 Critical | OpenSSH Private Key |
| SR052 | 🔴 Critical | PGP Private Key |
| SR053 | 🔴 Critical | EC Private Key |

### Generic / contextual

| ID | Severity | Detects |
|:---|:---:|:---|
| SR060 | 🟡 Medium | Generic `api_key=...` assignment (entropy-checked) |
| SR061 | 🟠 High | Generic `password=...` assignment |
| SR062 | 🟠 High | Generic `secret=...` assignment |
| SR063 | 🔴 Critical | DB connection string with credentials |
| SR064 | 🟠 High | HTTP URL with embedded credentials |

---

## ⚙️ Configuration

Create `.secradar.toml` in your repo root:

```toml
# Skip specific rules (comma-separated)
skip-rules = ["SR031", "SR062"]

# Only run specific rules
# only-rules = ["SR001", "SR002", "SR010"]

# Minimum severity to report (info | low | medium | high | critical)
# min-severity = "medium"

# Custom entropy threshold (lower = more sensitive)
# min-entropy = 4.0

# File size limit in bytes
max-file-size = 1048576

# Threads (default: all cores)
# threads = 4

# Exclude patterns (glob)
exclude = ["**/test/**", "**/tests/**", "**/*.example"]
```

CLI flags override config file settings.

---

## 📊 Output Formats

### Pretty (default)

```
  ▸ .env.production
    CRITICAL  [SR001] AWS Access Key ID
      3:15
      match:  AKIA****MPLE

  ──────────────────────────────────────────────────────────
  Total: 1 critical, 2 high, 1 medium
```

### JSON

```json
{
  "tool": "secradar",
  "version": "1.0.0",
  "count": 4,
  "findings": [...],
  "summary": {"CRITICAL": 1, "HIGH": 2, "MEDIUM": 1}
}
```

### SARIF

Renders as GitHub code scanning annotations in PRs.

---

## 🛠️ Development

```bash
cargo build              # debug
cargo build --release    # optimized
cargo test               # 10 unit tests
cargo run -- .           # scan current dir
```

### Add a new rule

Edit `src/rules.rs`:

```rust
Rule {
    id: "SR999",
    name: "My Custom Token",
    description: "Detects MyCustom tokens",
    severity: Severity::High,
    regex: MY_CUSTOM_REGEX.as_ref(),
    min_entropy: 3.5,
},
```

Add the regex at the bottom of the file, then add a test in `#[cfg(test)] mod tests`.

---

## 🔧 Tools Compared

| Tool | Language | Speed | Rules | Local |
|---|---|---|---|---|
| **secradar** | Rust | ⭐⭐⭐⭐⭐ | 30 | ✅ |
| [gitleaks](https://github.com/gitleaks/gitleaks) | Go | ⭐⭐⭐⭐ | 100+ | ✅ |
| [trufflehog](https://github.com/trufflesecurity/trufflehog) | Python | ⭐⭐⭐ | 700+ | ✅ |
| [detect-secrets](https://github.com/Yelp/detect-secrets) | Python | ⭐⭐ | 25 | ✅ |

---

## 📜 License

MIT © 2026 Afiq Andico Pangimpian