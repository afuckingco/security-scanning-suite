# Changelog

All notable changes to secradar will be documented in this file.

## [1.0.0] - 2026-06-23

### Added
- Initial release
- **30 detection rules** covering cloud, source control, communication, payment, auth tokens, private keys, generic patterns
- **Shannon entropy**-based detection for unknown secrets
- **Git history scanning** via git2 (libgit2 bindings)
- **4 output formats**: pretty (terminal), JSON, SARIF, compact
- **`.secradar.toml`** config support (skip-rules, only-rules, severity filter, excludes, threads)
- **Parallel scanning** with rayon (multi-core)
- **`.gitignore`-aware** file traversal via `ignore` crate
- **Performance**: LTO + codegen-units=1 + opt-level=3 release build
- **10 unit tests** covering entropy, rules, edge cases

### Privacy
- Zero network calls — all processing local
- No Twitter/LinkedIn/Instagram/WhatsApp references (per user request)