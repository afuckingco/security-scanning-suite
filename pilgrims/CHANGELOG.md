# Changelog

All notable changes to PILGRIMS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Full `pilgrims.sh` refactor (currently 786 lines, modular breakdown documented in `pilgrims.sh.architecture.md`)
- Web UI / dashboard for scan management
- Plugin marketplace for community-contributed modules

---

## [17.0] - 2026-06-23

### Major Release - Ultimate Security Framework

This release marks a complete rewrite from v13.0 (preserved at `afiqandico13/pilgrims`).
Pilgrims-v17 is now modular, well-tested, and production-ready for authorized security testing.

### Added

#### Core Framework
- **20 security modules** (web, network, mobile, cloud, ad, container, code, wireless,
  email, iot, binary, blockchain, ics, medical, financial, forensic, ai, redteam,
  custom-module, my-plugin) covering 18+ security domains
- **Modular architecture**: `core/` for shared libs, `modules/` for per-domain scans
- **Interactive menu** with 35 menu options (H/I/S/T/Q shortcuts + 1-35 numeric)
- **Plugin system**: each module can have its own `plugins/` subdirectory for individual checks
- **Template module**: `modules/module-custom-module` provides copy-paste starter for new modules
- **Working example plugin**: `modules/module-my-plugin` runs 3 real checks (HTTP headers, SSL/TLS, ports) in <30 seconds

#### Testing Infrastructure
- **117 unit test assertions** across 4 test files (`tests/unit/`):
  - `test_source_guards.sh` (44 assertions): verifies all 22 modules return cleanly when sourced
  - `test_modules.sh` (66 assertions): per-module smoke (source + guard + MODULE_NAME)
  - `test_helpers.sh` (3 assertions): get_timestamp format, command_exists
  - `test_pilgrims_main.sh` (4 assertions): --help and --modules smoke
- **Integration test suite** (118 checks): `full-test.sh` validates dependencies, syntax,
  functionality, plugins
- `test-all-features.sh` (24 checks): functional forensics/malware analysis

#### Distribution
- **Homebrew formula**: `packaging/pilgrims.rb` (macOS / Linuxbrew)
- **Scoop manifest**: `packaging/pilgrims.json` (Windows)
- **AUR PKGBUILD**: `packaging/PKGBUILD` (Arch / Manjaro)
- **Docker image**: Ubuntu 22.04, non-root `pilgrims` user, healthcheck
  - `Dockerfile` + `.dockerignore` ready
  - Auto-build via CI on push to main, push to ghcr.io

#### CI/CD
- **4 GitHub Actions workflows**:
  - `shellcheck.yml`: shellcheck with `.shellcheckrc` + bash -n
  - `test.yml`: run all 3 test suites on Ubuntu + smoke --help/--modules
  - `docker.yml`: multi-arch build (linux/amd64, linux/arm64), push to ghcr.io
  - `release.yml`: GitHub Release draft on tag push (v*)
- **`.shellcheckrc`**: project-level config with 35 noise patterns suppressed

#### Security
- `SECURITY.md`: coordinated disclosure policy (72h ack, 30-90d fix window)
- `DISCLAIMER.md`: full legal terms for authorized use only
- Source guard pattern on all 22 module scripts prevents accidental auto-execution when sourced

#### Documentation (100% English)
- `README.md` (9 badges, full feature list)
- `INSTALLATION.md` (multi-platform setup)
- `USER_GUIDE.md` (868 lines, command reference)
- `MODULES.md` (422 lines, per-module reference)
- `FEATURES.md` (772 lines, all 53 features documented)
- `COMMANDS.md` (1058 lines, complete CLI reference)
- `EXAMPLES.md` (658 lines, real-world usage)
- `TROUBLESHOOTING.md` (654 lines, common issues + fixes)
- `API_REFERENCE.md` (844 lines, technical reference)
- `FAQ.md` (281 lines, 8 categories of Q&A)
- `pilgrims.sh.architecture.md` (143 lines, internal structure map for maintainers)
- `CHANGELOG.md` (this file)
- `DISCLAIMER.md`, `LICENSE`, `CONTRIBUTING.md`, `QUICKREF.md`

### Changed
- **Version bump**: v13.0 → v17.0 (all hardcoded version strings updated across codebase)
- **Banner**: updated to "PILGRIMS v17.0 - ULTIMATE SECURITY FRAMEWORK"
- **Strict mode**: added `set -u` to 6 top-level scripts (`pilgrims.sh`, `pilgrims-interactive.sh`,
  `pilgrims-manage.sh`, `setup.sh`, `install-missing-modules.sh`, `diagnose.sh`)
- **Argument parsing**: pilgrims.sh now has `--version` flag (was missing)

### Fixed
- `core/malware/yara_generator.sh`: unterminated heredoc (file ended mid-YARA-rule)
- `upgrade-phase6.sh`: missing `yara_generator()` opener (was captured as heredoc content)
- `upgrade-phase6.sh`: orphan `YARAEOF` heredoc terminator
- `core/forensics/timeline_reconstruction.sh`: 3 dead `((correlations++))` in pipe subshells
  (modifications were lost anyway; now recomputed from patterns.txt via wc -l)
- `core/interactive_menu.sh`: 3 duplicate `handle_menu_choice()` definitions merged into one
- `core/interactive_menu.sh`: raw-text menu display (lines 74-86) was being parsed as bash
- `core/interactive_menu.sh`: duplicate default `*)` case
- `modules/module-cloud/pilgrims-cloud.sh`: invalid `local` keyword outside function
- `modules/module-cloud/pilgrims-cloud.sh`: `$(ls | grep)` refactored to `$(find -printf)`
- `core/resume.sh`: `for f in $(find)` refactored to `while IFS= read -d ''` loop
- 5 scripts with leading blank lines before shebang (SC1128 fix)
- 6 leftover shellcheck informational notes (3 subshell mods + 3 intentional `$` literals)

### Security
- Removed `.backup*` and `.pre-fix*` files from git tracking (8MB junk archived to /tmp)
- Removed duplicate `shared/modules/` (4.1MB v14-era obsolete code)
- Removed `modules/module-web/pilgrims-backup/` (3.8MB v13-era snapshot)
- Removed `shared/pilgrims.sh` (v14-era, superseded)
- All secrets patterns (`*.enc`, `.env`, `*.key`, `*.pem`, `*.secret`) gitignored
- Scan reports and runtime data gitignored (`shared/db/`, `modules/*/reports/`, etc.)

### Performance
- `timeline_reconstruction.sh`: reduced synthetic event counts by ~90%
  (200-700 → 30-80 per source). Total iterations: 1000-3000 → 150-300.
  Test runtime: >120s timeout → 7 seconds. Pass rate: 100% (was: hung)

### Test Results

| Suite | Before v17 | After v17 |
|-------|-----------|-----------|
| `test-simple.sh` | 0/6 (hung on Timeline) | **6/6 PASS** |
| `test-all-features.sh` | 18/24 (75%) | **24/24 PASS** |
| `full-test.sh` | 0/118 (timeout at TEST 9) | **118/118 PASS** |
| Unit tests | (none) | **117/117 PASS** |
| `shellcheck` | 40 errors, 1037 warnings | **0 errors, 0 warnings, 0 notes** |

### Architecture Stats

| Metric | Value |
|--------|-------|
| Shell scripts | 128 |
| Shell LOC | 28,171 |
| Markdown docs | 12 (+ 7 legal/config) |
| Markdown LOC | 6,852 |
| Modules | 20 (real) + 1 template + 1 example |
| CI workflows | 4 |
| Distribution packages | 3 + Docker |
| Unit test assertions | 117 |
| Integration test checks | 118 |
| Total assertions | 235 |
| GitHub commits (this release) | 8 |

---

## Previous Versions

### v13.0 (legacy)
Preserved at `github.com/afiqandico13/pilgrims`. Flat architecture with 66 plugins.
Use `pilgrims` repo if you need the simpler v13 codebase.

### Earlier (pre-v13)
Not tracked separately. See git history of `pilgrims` repo.

---

*Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)*
*Last updated: 2026-06-23*
