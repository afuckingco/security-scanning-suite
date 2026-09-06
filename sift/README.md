# 🔍 Sift

**Ultra-fast, zero-dependency CLI security scanner for hardcoded secrets.**

[![Go Version](https://img.shields.io/badge/Go-1.21%2B-00ADD8?logo=go&logoColor=white)](https://golang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Dependencies](https://img.shields.io/badge/dependencies-0-brightgreen)]()
[![Binary Size](https://img.shields.io/badge/binary-%3C2.5MB-blue)]()
[![CI](https://github.com/afuckingco/sift/actions/workflows/ci.yml/badge.svg)](https://github.com/afuckingco/sift/actions/workflows/ci.yml)

Sift scans your codebase for hardcoded secrets, API keys, and risky configuration patterns — combining **pattern-based rules** with **Shannon entropy analysis** to catch both known secret formats and unknown, obfuscated ones. It ships as a single static binary with zero external dependencies, built entirely on the Go standard library.

---

## Table of Contents

- [Why Sift](#why-sift)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [CLI Reference](#cli-reference)
- [Detection Engine](#detection-engine)
- [Built-in Rules](#built-in-rules)
- [Custom Rules](#custom-rules)
- [CI/CD Integration](#cicd-integration)
- [Project Architecture](#project-architecture)
- [Development](#development)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Why Sift

Most secret scanners fall into one of two camps: heavyweight tools with dozens of dependencies and slow startup times, or simple regex greps that miss anything that doesn't match a known pattern. Sift aims for a narrower, sharper niche:

| | Sift |
|---|---|
| **Dependencies** | Zero — 100% Go standard library |
| **Binary size** | ~2.3 MB, single static file |
| **Startup time** | < 100ms |
| **Detection method** | Regex rules + Shannon entropy (catches unknown/obfuscated secrets) |
| **Concurrency** | Yes — worker-pool file scanning |
| **Git-aware mode** | Scans only changed files (`--git-diff`) |
| **Custom rules** | Plain-text `.siftrules` format, no config language to learn |
| **CI/CD output** | Native JSON output for pipeline parsing |

Sift is intentionally minimal. It does not phone home, does not require a config server, and does not need a package manager to install. Clone it, build it, run it.

## Installation

### Download a prebuilt binary

Grab the latest release for your platform from the [Releases page](https://github.com/afuckingco/sift/releases):

```bash
# Linux
curl -L https://github.com/afuckingco/sift/releases/latest/download/sift-linux-amd64 -o sift
chmod +x sift

# macOS (Apple Silicon)
curl -L https://github.com/afuckingco/sift/releases/latest/download/sift-macos-arm64 -o sift
chmod +x sift
```

```powershell
# Windows (PowerShell)
Invoke-WebRequest -Uri "https://github.com/afuckingco/sift/releases/latest/download/sift-windows-amd64.exe" -OutFile "sift.exe"
```

### Build from source

Requires Go 1.21+.

```bash
git clone https://github.com/afuckingco/sift.git
cd sift
go build -ldflags="-s -w" -o sift .
```

Or with `make`:

```bash
make build
```

Verify the install:

```bash
./sift --version
```

## Quick Start

```bash
# Scan the current directory
./sift .

# Scan only files changed in the last commit (fast, for CI on pull requests)
./sift --git-diff .

# Machine-readable output for pipelines
./sift --json . > report.json

# Use a custom rules file
./sift --rules .siftrules .
```

Example output:

```
🔍 Sift v1.0.0: Smart & Extensible Security Scanner

✅ Loaded 5 default rules + 2 custom rules.

⚠️  Found 1 issues in 3.2ms:

[CRITICAL] AWS Access Key (S001)
  config/settings.go:14
  | awsKey := "AKIAIOSFODNN7EXAMPLE123"
```

Sift exits with status code `1` if any `CRITICAL` or `HIGH` severity finding is present — making it a drop-in gate for CI pipelines and pre-commit hooks.

## CLI Reference

| Flag | Description | Default |
|---|---|---|
| `--json` | Output findings as JSON instead of formatted terminal text | `false` |
| `--git-diff` | Scan only files changed in the last commit (falls back to a full scan outside a git repo) | `false` |
| `--rules <path>` | Path to a custom rules file, merged with the built-in rules | `.siftrules` |
| `--version` | Print the version and exit | — |
| `[directory]` | Positional argument: directory to scan | `.` |

## Detection Engine

Sift combines two complementary detection strategies:

**1. Pattern matching** — a set of regular expressions targeting known secret formats (cloud provider keys, private key headers, generic token assignments) and risky configuration patterns (Dockerfile misconfigurations).

**2. Shannon entropy analysis** — for everything a fixed pattern can't anticipate. Sift extracts quoted string literals from source files and calculates their [Shannon entropy](https://en.wikipedia.org/wiki/Entropy_(information_theory)):

```
H(X) = -Σ p(x) · log₂ p(x)
```

A string with high character diversity and low predictability (a genuinely random-looking token) scores a high entropy value. Low-entropy strings — regular words, short identifiers, repeated characters — score low and are ignored. This lets Sift flag secrets in formats it has never seen before, at the cost of requiring some tuning to avoid false positives.

To keep noise low, the entropy engine also filters out common high-entropy-but-benign patterns before flagging:

- JWTs (three dot-separated base64url segments)
- UUIDs (standard 8-4-4-4-12 hex format)

A string is flagged as a likely secret if its entropy exceeds `5.2`, and it either mixes uppercase, lowercase, and digits, or exceeds an entropy of `5.8` outright.

## Built-in Rules

| ID | Description | Severity |
|---|---|---|
| `S001` | AWS Access Key (`AKIA`, `ASIA`, and related prefixes) | CRITICAL |
| `S002` | Generic secret/token/password assignment (`api_key = "..."`, etc.) | HIGH |
| `S003` | Private key block (`-----BEGIN ... PRIVATE KEY-----`) | CRITICAL |
| `D001` | Dockerfile running as `USER root` | MEDIUM |
| `D002` | Dockerfile using a `:latest` image tag | LOW |
| `ENT01` | High-entropy string literal (Shannon entropy engine) | HIGH |

## Custom Rules

Add project-specific detection rules by dropping a `.siftrules` file in your project root (or pointing `--rules` at any path). Format:

```
# Sift Custom Rules
# ID | Severity | Regex | Description

CUST01 | HIGH   | (?i)internal_db_pass\s*=\s*['"].+['"] | Internal DB Password Leak
CUST02 | MEDIUM | (?i)192\.168\.\d{1,3}\.\d{1,3}         | Hardcoded Internal IP Address
```

Rules:
- One rule per line, pipe-delimited: `ID | SEVERITY | REGEX | DESCRIPTION`
- Lines starting with `#` and blank lines are ignored
- `SEVERITY` must be one of `CRITICAL`, `HIGH`, `MEDIUM`, `LOW`
- Invalid regex or malformed lines are skipped with a warning — they will never crash a scan
- Custom rules are additive; they run alongside the 6 built-in rules

## CI/CD Integration

### GitHub Actions

Sift ships with a working [`.github/workflows/ci.yml`](.github/workflows/ci.yml) that runs tests, builds the binary, and — on tagged releases — cross-compiles binaries for Linux, macOS, and Windows. Drop this into any repo to gate pull requests on secret scanning:

```yaml
- name: Run Sift
  run: |
    curl -L https://github.com/afuckingco/sift/releases/latest/download/sift-linux-amd64 -o sift
    chmod +x sift
    ./sift --git-diff .
```

The scan fails the job automatically if any `CRITICAL` or `HIGH` finding is present.

### Pre-commit hook

```bash
#!/bin/sh
# .git/hooks/pre-commit
./sift --git-diff . || {
  echo "❌ Sift found potential secrets. Commit blocked."
  exit 1
}
```

## Project Architecture

```
sift/
├── main.go                # CLI entry point, flag parsing, exit codes
├── engine.go               # Concurrent file scanner, git-diff mode, worker pool
├── rules.go                # Default rule definitions + custom rule file parser
├── entropy.go               # Shannon entropy calculation and secret heuristics
├── output.go               # Terminal (colorized) and JSON output formatting
├── sift_test.go            # Unit tests covering entropy, rules, scanning, output
├── .siftrules               # Example custom rules file
├── Makefile                 # build / test / clean / release targets
└── .github/workflows/       # CI: test, build, cross-compile on tag
    └── ci.yml
```

Scanning is parallelized across a fixed worker pool (4 goroutines) reading from a buffered channel of file paths, with a mutex-guarded shared findings slice. File discovery skips hidden directories, `node_modules`, `vendor`, and `target`, and ignores files over 2MB and symlinks, to keep scans fast and safe on large repositories.

## Development

```bash
make build      # Build the binary for your platform
make test       # Run the test suite (uses -race when cgo is available)
make clean      # Remove built binaries
make release    # Cross-compile for linux/amd64, darwin/amd64, darwin/arm64, windows/amd64
```

Running tests directly:

```bash
go test -v ./...
```

> **Note (Windows):** the Go race detector (`-race`) requires cgo, which needs a C compiler (e.g. MinGW-w64) not installed by default on Windows. `make test` detects this automatically and falls back to a standard (non-race) test run with a warning.

## Roadmap

- [ ] Config file support (`.sift.yml`) for default flags and ignore paths
- [ ] `--ignore` flag / `.siftignore` file for path exclusions
- [ ] Baseline/allowlist support for accepted false positives
- [ ] Additional built-in rules (GCP, Azure, Slack, Stripe, generic PEM formats)
- [ ] SARIF output for GitHub code scanning integration
- [ ] Pre-built `pre-commit` framework hook definition

## Contributing

Contributions are welcome. The project's one hard constraint: **zero external dependencies** — Go standard library only. This is a deliberate design choice, not a limitation to work around.

1. Fork the repo and create a feature branch
2. Run `make test` before opening a PR — all tests must pass
3. New detection rules should include a corresponding test case in `sift_test.go`
4. Open a PR with a clear description of the change and rationale

## License

MIT License — see [LICENSE](LICENSE) for details. by afuckingco

---

**Built by [@afuckingco](https://github.com/afuckingco)**
