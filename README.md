# Security Lab

Konsolidasi tool keamanan, demo, dan laporan (2026-09-06). Setiap komponen berada di
subfolder dengan README dan lisensinya sendiri.

## Komponen

### Scanner & CLI
| Komponen | Bahasa | Fungsi |
|---|---|---|
| [sift/](sift/) | Go | Secret scanner zero-dep (entropy, `git history`) — binary <2.5MB |
| [dockguard/](dockguard/) | Python | Linter & analisa Dockerfile — 10 rules, CI-friendly |
| [log-anonymizer/](log-anonymizer/) | Python | Anonimisasi log (CLI, FastAPI, Docker, CI/CD) |
| [sec-scan-cli/](sec-scan-cli/) | Python | CLI scan terpadu + pipeline CI/CD (npm audit, pip-audit, gitleaks, Suricata — report, artifact, Slack) |

### CI/CD & Operasi
| Komponen | Fungsi |
|---|---|
| [secure-ops-suite/](secure-ops-suite/) | Suite operasi keamanan (anomaly detection + npm/PyPI proxy) |

### Web & Demo
| Komponen | Bahasa | Fungsi |
|---|---|---|
| [secure-express-shop/](secure-express-shop/) | JavaScript/Express | E-commerce defensif (helmet, CSRF, rate limiting, session) |
| [dvwa-portfolio/](dvwa-portfolio/) | Python/DVWA | Demo & analisis DVWA (setup, recon, SQLi) — lihat [README](dvwa-portfolio/README.md) |

### Lainnya
| Komponen | Fungsi |
|---|---|
| [link-cleaner/](link-cleaner/) | Ekstensi browser (MV3) penghapus 88 parameter tracking |
| [pilgrims/](pilgrims/) | Framework pentest 20 modul (untuk use-case yang diotorisasi) |
| [anf-research-shell/](anf-research-shell/) | Research workbench reproduktif (CLI zsh, `make verify` 25 gate, CI) — konsolidasi dari repo ANF-Research-Shell (2026-09-07) |

## Satu CLI: `seclab`

Semua tool di repo ini bisa dipakai lewat **satu entry point** (unified CLI):

```bash
./seclab list              # daftar tool
./seclab doctor            # cek runtime yang tersedia
./seclab scan-secret .     # sift — scan hardcoded secrets
./seclab lint-docker Df    # dockguard — lint Dockerfile
./seclab anon-log in.csv out.csv --algorithm hash
./seclab scan --help       # sec-scan-cli
./seclab ci-scan           # sec-scan-cli — pipeline scan (npm/pip/gitleaks)
./seclab pilgrims --help   # framework pentest
./seclab anf               # research workbench
```

`seclab` hanya men-dispatcher; tiap tool tetap berjalan di subfoldernya dengan
runtime/bahasanya sendiri (lihat tabel). Symlink opsional: `ln -s seclab ~/.local/bin/seclab`.

## Penggunaan Cepat (contoh)

```bash
# scan secret di repo lokal
cd sift && sift scan --path ./project --format pretty
# analisa Dockerfile
cd dockguard && dockguard lint ./Dockerfile --json
```

Detail per tool ada di README masing-masing subfolder.

## Catatan Etika

Tool di repo ini untuk *authorized* testing dan pembelajaran. `pilgrims`, `dvwa-portfolio`,
dan `reviews/` hanya digunakan pada lingkungan dengan izin eksplisit.

## Lisensi

MIT (lihat [LICENSE](LICENSE)) kecuali komponen yang membawa lisensinya sendiri.
