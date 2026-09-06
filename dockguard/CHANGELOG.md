# Changelog

All notable changes to dockguard will be documented in this file.

## [1.0.0] - 2026-06-23

### Added
- Initial release
- **10 security & best-practice rules**:
  - DG001: Container runs as root
  - DG002: ADD vs COPY for local files
  - DG003: Hardcoded secrets in ENV / ARG
  - DG004: `:latest` tag usage
  - DG005: `apt-get install` without cleanup
  - DG006: `curl | sh` / `wget | sh` patterns
  - DG007: Missing HEALTHCHECK
  - DG008: Unpinned pip/npm packages
  - DG009: Excessive RUN layers
  - DG010: No multi-stage build (when build tools present)
- **3 output formats**: pretty (terminal), JSON, GitHub Actions annotations
- **3 severity levels**: error, warning, info
- **CI-friendly exit codes**: 0=clean, 1=warnings, 2=errors
- **`.dockguard.yml` config** for ignore-rules / ignore-severity / enabled-rules
- **Zero dependencies** — pure Python stdlib
- **30+ tests** covering parser, rules, reporter