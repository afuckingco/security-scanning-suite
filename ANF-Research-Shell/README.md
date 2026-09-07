# ANF Research Shell

[![CI anf-verify](https://github.com/afiqandico/security-lab/actions/workflows/anf-verify.yml/badge.svg)](https://github.com/afiqandico/security-lab/actions/workflows/anf-verify.yml)

**Integrated & Reproducible Research Workbench — satu terminal untuk pekerjaan peneliti (science, math, CS), dengan output terukur dan tertelusur.**
*Sebelumnya: AFUCKINGCO. v1.0.0 = rebrand + struktur enterprise/research; v1.5.0+ = fokus research workbench (cyber tidak dipromosikan).*

ANF membungkus perhitungan ilmiah, ML/DL, visualisasi, scaffolding eksperimen, dan verifikasi reproducibility ke satu CLI yang deterministik dan teruji.

---

## Kenapa ANF (positioning — satu cerita)
**ANF = Integrated & Reproducible Research Workbench.** Bukan sekadar shell, tapi satu terminal tempat semua pekerjaan peneliti (science, math, computer science) bisa dijalankan **konsisten, terukur, dan tertelusur**:

- **Science & Math** — statistik, kalkulator, matematika simbolik, visualisasi
- **ML / DL / Eval** — stack-check, benchmark deterministik, DL smoke test, scaffold eksperimen, data wrangling, bibliografi
- **Reproducible** — seed deterministik, manifest, 25-test suite, output numerik ke `research/outputs/`
- **Self-contained / Rapi** — auto-install tool Linux (`/ensure`), installer, git, docs

Jalankan `anf why` untuk ringkasan; `research/PAPER_OUTLINE.md` & manifest untuk rencana manuskrip dan bukti baseline.

---

## Instalasi
```bash
./install.sh                 # instal ke /usr/local/bin + config + lib
# atau tanpa root:
./install.sh --prefix "$HOME/.local"
```

## Penggunaan
```bash
anf                # shell interaktif (ZLE popup + banner)
anf help           # daftar semua command
anf encode hello   # aGVsbG8=
anf hash abc       # MD5/SHA256/SHA512
anf status         # status sesi
anf envcard        # ringkasan sistem & tools
anf task start demo "python3 train.py"   # task tmux latar (survive restart)
anf task list      # daftar task
anf q "pattern" .  # pencarian cepat grep
anf gitx s         # git status ringkas
anf gen "buat script backup"   # AI-assisted code gen (hermes/opencode)
```

Di dalam shell: `/gen`, `/task`, `/q`, `/gitx`, `/envcard`, `/mvp` (alias `/cmd`).

## Research Suite — untuk peneliti (science, math, computer science)
Semua pekerjaan riset dalam satu terminal:
```bash
anf mlinfo                    # stack ML/DL: torch/sklearn/numpy/CUDA
anf stat data.txt             # statistik dataset: mean/median/std/entropy
anf mlbench 400               # benchmark deterministik → research/outputs/*.csv
anf dlcheck                   # smoke test DL CPU (torch, seed=42)
anf dlcheck full              # mini-MLP 3 epoch synthetic
anf paperstat manuscript.md   # statistik kata/baris/ref manuskrip
```
Fungsi historis (mis. `anf matrix` / MITRE ATT&CK, `c2-*`) tetap tersedia untuk kompatibilitas
namun tidak dipromosikan sejak v1.6.0 — lihat CHANGELOG.
Hasil benchmark ditulis otomatis ke `research/outputs/` — bukti numerik untuk reproducibility.

## Researcher Workflow (semua via terminal)
```bash
anf plot data.csv 2 hist "judul"   # visualisasi -> research/outputs/*.png
anf calc "sqrt(144)"               # kalkulator ilmiah
anf sym "integrate(x**2, x)"       # matematika simbolik (sympy)
anf sha manuscript.tex             # checksum reproducibility
anf exp nama_eksperimen            # scaffold: folder+seed+env+run.sh
anf csv summary data.csv           # data wrangling (pandas)
anf bib references.bib             # validasi bibliografi
```

## Auto-Provisioning (Linux)
Tool yang belum terpasang otomatis di-install:
```bash
anf ensure doctor   # cek tool wajib (dry, aman)
anf ensure all      # auto-install yang kurang (konfirmasi dulu, butuh sudo)
```
Mendukung apt (Debian/Ubuntu), dnf (Fedora), pacman (Arch), brew (fallback). Fokus **Linux dulu** untuk stabilitas.

## Verifikasi (reproducibility)
```bash
zsh -n code/anf_research_shell.zsh        # MUST: SYNTAX OK
python3 code/test_suite.py                # MUST: 25/25 pass
bin/anf hash abc                          # MD5 90015098...
```

## Reproducibility Enterprise — satu perintah utk SEMUA deliverable
`make verify` = baseline ANF + 3 deliverable paper (JSI1 mini-SOC, JSI2 VAE/SLR,
JSI3 DCA) — semua dijalankan di **sandbox** (tanpa polusi ke repo), dicek hash
dan nilai ilmiah terhadap `research/outputs/reproducibility_manifest.md`.

```bash
make setup     # python3 -m venv .venv && pip install -r requirements.txt (pin)
make verify    # 25 gate: PASS 25 / FAIL 0 / SKIP 0 — hijau di CI GitHub Actions (2026-09-07)
```
CI GitHub Actions aktif: `.github/workflows/anf-verify.yml` (root security-lab, paths-filtered —
menjalankan `make verify` otomatis di setiap perubahan folder `ANF-Research-Shell/`). Lisensi kode: MIT (`LICENSE`).

**Berdiri sendiri (standalone):** seluruh script eksperimen sudah di-vendor di
`research/outputs/exp_*/` (verbatim, sha tercatat di manifest); interpreter
di-resolve dari `$PYTHON` → `.venv/` repo-local → `$HOME/venv` → `python3`,
tanpa path berkas/repo luar. `make setup` + deps ter-pin cukup untuk membangun
& memverifikasi semuanya. Authorship & AI disclosure: lihat `NOTICE.md`.

---

## Struktur
```
ANF-Research-Shell/
├── bin/anf                  # launcher CLI
├── Makefile                 # make setup / verify / test (enterprise reproducibility)
├── requirements.txt         # dependensi pin agregat (semua deliverable)
├── LICENSE                  # MIT (kode)
├── NOTICE.md                # authorship + AI disclosure + pernyataan standalone
├── .github/workflows/ci.yml # CI: make verify di push/PR
├── code/anf_research_shell.zsh  # script inti (64 fungsi, fokus riset; modul cyber diarsipkan terpisah)
├── code/test_suite.py       # 25 test deterministik
├── code/anfrc.dist          # template konfigurasi
├── docs/CHANGELOG.md        # riwayat versi
├── research/PAPER_OUTLINE.md
├── research/outputs/        # manifest + hasil eksperimen (artefak besar di-ignore; source & manifest di-track)
├── research/archive/        # artefak uji-coba yang diarsipkan (bukan dihapus)
├── scripts/verify_repro.sh  # verifikasi end-to-end reproducible (sandbox, cek hash vs manifest)
├── server/                  # placeholder (C2 server historis, tidak dipromosikan)
├── packages/                # placeholder modular (future)
└── install.sh               # installer
```

## Kontribusi & etika
Tool untuk **riset keamanan dan edukasi** (lingkungan lab/sendiri). Tidak untuk aktivitas ilegal. Penggunaan di luar lingkungan Anda sendiri menjadi tanggung jawab pengguna.

## AI disclosure
Tool dikembangkan & didokumentasikan dengan bantuan AI (Hermes, model DeepSeek V4 Flash). Penulis utama: **Afiq Andico Pangimpian** (Independent Researcher).

## Lisensi
Kode: **MIT** (lihat `LICENSE`, 2026). Dokumen: proposal CC-BY (menyusul bila perlu). Lihat manifest.
