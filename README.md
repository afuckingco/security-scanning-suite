# Security Lab

Konsolidasi tool keamanan CLI (2026-09-07). Kebijakan: **fokus project CLI saja**
(komponen non-CLI — web demo, ekstensi browser, suite docker — sudah dihapus).
Setiap komponen berada di subfolder dengan README dan lisensinya sendiri.

## Komponen

### Scanner & CLI
| Komponen | Bahasa | Fungsi |
|---|---|---|
| [sift/](sift/) | Go | Secret scanner zero-dep (entropy, `git history`) — binary <2.5MB |
| [dockguard/](dockguard/) | Python | Linter & analisa Dockerfile — 10 rules, CI-friendly |
| [log-anonymizer/](log-anonymizer/) | Python | Anonimisasi log (CLI, FastAPI, Docker, CI/CD) |
| [sec-scan-cli/](sec-scan-cli/) | Python | CLI scan terpadu + pipeline CI/CD (npm audit, pip-audit, gitleaks, Suricata — report, artifact, Slack) |

### Lainnya
| Komponen | Fungsi |
|---|---|
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

Tool di repo ini untuk *authorized* testing dan pembelajaran. `pilgrims`
hanya digunakan pada lingkungan dengan izin eksplisit.

## Lisensi

MIT (lihat [LICENSE](LICENSE)) kecuali komponen yang membawa lisensinya sendiri.
