# Changelog — dockguard

## v1.0.0 — 2026-09-06
Rilis publik pertama (Python stdlib).

### Fitur
- 10 rule lint Dockerfile (USER, HEALTHCHECK, base image tag, dsb.)
- CLI: `--format json|github|pretty`, `--quiet`, `--ignore <rules>`
- Exit code: 0 bersih / 1 ada finding / 2 file tidak ditemukan
- Output kompatibel GitHub Actions
