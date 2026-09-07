# CHANGELOG — ANF Research Shell

## Catatan Infra Reproducibility & Enterprise (2026-09-07, setelah v1.6.1)
Tidak ada command/versi baru — infrastruktur reproducibility (lihat manifest §10):
- `make verify` / `make test` → **25 gate** (A baseline + B JSI1 mini-SOC + C JSI2 VAE/SLR + D JSI3 DCA) di sandbox tmp, hash vs manifest; **hijau di CI GitHub Actions** (PASS 25/0/0, 2026-09-07).
- `make setup` + `requirements.txt` agregat ter-pin (xgboost 3.4.1, scikit-learn 1.9.0, psutil 7.2.2, scapy 2.7.0, torch 2.13.0+cpu [index CPU], scipy 1.18.0, numpy 2.5.2, matplotlib 3.11.1).
- CI GitHub Actions: `.github/workflows/ci.yml` (push/PR → make verify; butuh repo di GitHub).
- `LICENSE` MIT (kode) ditetapkan; manifest §6 TODO lisensi ditutup.
- Deliverable JSI2 (VAE, scaffold `exp_jsi2_vae_*`) + JSI3 (DCA, build_artifact + gate) tergabung dalam verify.
- Verifikasi aktual: PASS 25 / FAIL 0 / SKIP 0 (CI GitHub Actions hijau; 2+ WARN timing/float DCA-JSI2 — desain, lihat manifest §10.3).

## v1.6.1 (Cyber dipisah dari ANF — keputusan user 2026-09-07)
**Tema: ANF bersih fokus research workbench. Modul operasional cyber dipindah ke arsip terpisah, bukan dihapus.**

### Perubahan
- **53 fungsi operasional cyber dipindah** dari `code/anf_research_shell.zsh` ke
  `~/Documents/Archive/ANF-cyber-modules-v1.6/anf_cyber_ops_*` (verbatim, tetap tersedia):
  Recon (`scan`, `subdomains`, `dns`, `whois`, `amass`, `nikto`, dll), C2 framework
  (`c2-start`, `c2-stop`, `c2-payload`, `c2-exfil`, dll), OSINT/exploit/defense
  (`osint-email`, `autopwn`, `suricata`, `priv-esc`, `persist`, `honeypot`, dll),
  IP/targets ops, `matrix` (MITRE mapping).
- **Script inti 119 → 64 fungsi** (3.085 → 2.414 baris).
- **Pangkat akar dipotong semuanya**: 46 entri `_ANF_CMD_DESC`, alias `/cmd`, help
  Core (`targets` dihapus), selftest (`check-ip`, tool nmap/subfinder → git/dig),
  `doctor` tool list (tool cyber dibuang), komentar section.
- **Metode riset dipertahankan**: `c2-entropy`, `c2-beacon-math`, `c2-ml-hunt`,
  `c2-zscore`, `eval-*`, `guardfall-metrics`, `benchmark-guardfall` — materi
  test_suite & paper, tidak dipromosikan sebagai cyber.
- Backup utuh: `~/Documents/Archive/ANF-cyber-modules-v1.6/anf_research_shell_v1.6.0_FULL_local.zsh`
  (per 2026-09-07 malam: arsip disimpan LOKAL di luar repo agar repo publik bersih dari modul cyber).

### Verifikasi v1.6.1 (semua lewat launcher `bin/anf`)
- `zsh -n` → SYNTAX OK (file final 2.414 baris)
- `test_suite.py` → 25/25 pass
- `bin/anf hash abc` → MD5 `90015098...` (deterministik)
- `bin/anf mlbench 200` → F1 entropy 1.0000 (output valid)
- `anf_selftest` → PASS 15, FAIL 0
- help → 6 ranah, 0 residu cyber

---

## v1.6.0 (Fokus Research — cyber dihilangkan dari promosi, 2026-09-06)
**Tema: mengerucut & fungsional. ANF = workbench riset (science/math/CS), bukan tool cyber.**

### Perubahan (menjawab user: "hilangkan saja cyber biar fokus lainnnya")
- **Help 20 kategori → 6 ranah besar**: Core, Utilities, Research & Math, ML/DL/Eval, Workbench & AI, Auto-Provisioning. Kategori cyber (Recon, Exploitation, OSINT, C2 Framework, Defense, Post-Exploitation, Network&OPSEC) dihapus dari promosi.
- **Banner** tanpa baris Cyber/Purple-Team → Science&Math / ML-DL-Research / Researcher tools / One-terminal.
- **`/why`** tanpa baris cyber; positioning: peneliti science/math/computer science.
- **README** positioning disamakan (tanpa cyber).
- **Konservatif**: fungsi cyber TIDAK dihapus — tetap bisa dipanggil manual (mis. `anf matrix`) untuk keperluan historis; hanya tidak dipromosikan.

### Verifikasi v1.6.0 (ad-hoc, mktemp)
- `zsh -n` → SYNTAX OK
- help → 6 ranah tampil; 0 kategori cyber tersisa di help ✅
- banner & `/why` → tidak memuat "cyber" ✅
- Regresi: test_suite 25/25, calc, sym, csv error handling ramah, ensure ✅
- Konservatif: `anf matrix` masih bisa dipanggil ✅

---

## v1.5.1 (Refokus Positioning — Integrated & Reproducible Research Workbench, 2026-09-06)
**Tema: rapikan & fokus satu cerita kuat, bukan 5 pilar serba tanggung.**

### Perubahan (menjawab arah user: "pangkas & refokus, positioning tunggal")
- **Positioning tunggal**: "Integrated & Reproducible Research Workbench" — semua pekerjaan peneliti (science, math, CS, cyber) dalam satu terminal yang reproducible. Menggantikan banner/why multi-pilar yang terpecah.
- **Versi diselaraskan**: `ANF_VERSION` 1.0.0 → **1.5.0** (sebelumnya kode bilang 1.0.0 padahal fitur sudah v1.5 — inkonsistensi diperbaiki).
- **Banner** di-refocus: 4 baris koheren (Science&Math / ML-DL-Research / Cyber-PurpleTeam / One-terminal + /ensure), bukan kolase fitur acak.
- **`/why`** = ringkasan positioning + pemetaan command per ranah + janji "terukur & tertelusur".
- **README & manifest** disamakan ke satu cerita.

### Verifikasi v1.5.1 (ad-hoc, mktemp)
- `zsh -n` → SYNTAX OK; `anf version` → 1.5.0
- Banner → v1.5.0 + "Integrated & Reproducible Research Workbench" ✅
- `/why` → headline + Positioning ✅
- Regresi: test_suite 25/25, encode hello, calc, sym, mlinfo, ensure, matrix ✅
- (Catatan: 1 "FAIL" pada run pertama terbukti bug test — case-sensitive grep "positioning" vs "Positioning"; kode benar.)

---

## v1.5.0 (Researcher Workflow + Auto-Provisioning, 2026-09-06)
**Tema: semua kebutuhan peneliti yang dikerjakan via terminal + tool otomatis ter-install.**

### Fitur baru (Section 15 — Researcher Workflow; Section 16 — Auto-Provisioning)
| Command | Fungsi | Ranah |
|---|---|---|
| `/plot` | Visualisasi data (hist/scatter/line) → PNG ke research/outputs (matplotlib) | Science |
| `/calc` | Kalkulator ilmiah (sqrt, trigonometri, pangkat) | Math |
| `/sym` | Matematika simbolik sympy: integrate/diff/simplify/limit/solve/series | Math |
| `/sha` | Checksum sha256 utk reproducibility manifest | Research |
| `/exp` | Scaffold eksperimen reproducible: folder + seed.txt + env.txt + run.sh | Research |
| `/csv` | Data wrangling CSV via pandas: head/summary/cols | Science |
| `/bib` | Validasi bibliografi .bib: count/duplikat/tipe/baris mencurigakan | Research/writing |
| `/ensure` | **Auto-provisioning**: cek tool wajib + auto-install yang belum ada (Linux apt/pacman/dnf; brew fallback) | DevOps |

### Verifikasi v1.5.0 (ad-hoc, mktemp)
- `zsh -n` → SYNTAX OK; total fungsi **119**; 3081 baris
- `test_suite.py` → **25/25**; alias 8/8; encode OK
- `/calc` → sqrt(144)=12, sin(pi/6)=0.5
- `/sym` → integrate=x³/3, simplify=x+1, limit=1, solve=[-2,2], diff=exp(x)(sin x+cos x)
- `/sha` → 64 hex; `/exp` → 3 file scaffold; `/csv` → baris=3; `/bib` → 2 entries
- `/ensure doctor` → deteksi apt + tool belum ada (dry, tanpa install)
- `/plot` → PNG ke research/outputs

### Bug fix dalam iterasi
- Glitch merge: `unset _cmd _func# ===` (newline hilang antar section) → fix
- sympy: `sp.sstr(r, pretty_print=False)` → `sp.sstr(r)` (API baru); inject sin/cos/exp/log/limit ke namespace
- Display `/ensure`: `, wait:wajib` → `[wajib]`

### Catatan auto-install (jawaban pertanyaan user)
**Bisa.** `/ensure doctor` cek; `/ensure all` auto-install via package manager Linux (apt/dnf/pacman) dengan konfirmasi sudo. Aman karena: (1) mode doctor kering default, (2) selalu konfirmasi sebelum install, (3) fokus Linux dulu untuk stabilitas.

---

## v1.4.0 (Researcher Workflow — batch 1) — digabung ke v1.5.0 di atas (satu commit)
*(v1.4 marker disimpan di git history; changelog dirangkum di v1.5.0.)*

## v1.3.0 (Research Suite — untuk peneliti science/math/CS/cyber, 2026-09-06)
**Tema: mempermudah SEMUA pekerjaan peneliti dalam satu terminal — riset, math, ML, DL, cyber.**

### Fitur baru (Section 14 — Research Suite)
| Command | Fungsi | Ranah |
|---|---|---|
| `/mlinfo` | Cek stack ML/DL: python/numpy/sklearn/torch + CUDA, jujur flag CPU | ML/DL |
| `/stat` | Statistik dataset numerik: n/min/max/mean/median/std/entropy | Math |
| `/mlbench` | Benchmark deterministik (seed=42): entropy-baseline vs IsolationForest → CSV ke research/outputs | ML/research |
| `/dlcheck` | Smoke test DL CPU: matmul (quick) / mini-MLP 3 epoch (full), deterministic | DL |
| `/matrix` | Mapping command ANF ke MITRE ATT&CK tactics (+ filter per tactic) | Cyber |
| `/dataset` | Registry dataset riset (add/list, persist ke `~/.cache/anf/datasets.tsv`) | Research |
| `/paperstat` | Statistik manuskrip (kata/baris/ref/ukuran) | Research |

### Verifikasi v1.3.0 (ad-hoc, mktemp, exit 0)
- `zsh -n` → SYNTAX OK; total fungsi **111**
- `test_suite.py` → **25/25** (regresi)
- Alias 7/7, help kategori **Research Suite** tampil
- `/mlinfo` → sklearn 1.9.0, torch 2.13.0+cu130 cuda=False (jujur CPU-only)
- `/stat` → mean=3, std=1.58114, entropy=2.32 bits (data 1..5)
- `/mlbench 400` → entropy-baseline F1=1.0, isolation-forest F1=0.205; CSV deterministik ke research/outputs
- `/dlcheck` quick → matmul shape 4x4; full → 3 epoch, loss turun, OK
- `/matrix` → C2/Recon/Defense tactics + filter reconnaissance
- `/dataset` add+list persist; header TSV tepat sekali
- `/paperstat` → kata/baris manuskrip

### Bug fix dalam iterasi
- `ANF_RESEARCH_DIR: parameter not set` → default `${ANF_RESEARCH_DIR:-$HOME/.../research/outputs}`
- **PITFALL zsh kritis:** `local path=...` di dalam fungsi menimpa `$PATH` (zsh tie array `path`↔PATH) → semua command not found (`dirname`/`mkdir`/`mv`/`date`). Fix: rename ke `pth`.
- `/dataset` header dobel → tulis header hanya jika file baru.

---

## v1.2.1 (Focus Value Proposition, 2026-09-06)
**Tema: mempertegas identitas — bukan shell tandingan, tapi cockpit riset keamanan.**

### Perubahan
- Command `/why` — value proposition ringkas (3 pilar: reproducible research, purple-team ops, AI-assisted).
- Banner fokus identitas: "Security-Research Cockpit │ Reproducible │ AI-assisted │ Purple-Team".
- README positioning ditulis eksplisit.

### Verifikasi v1.2.1
- `/why` → tagline + 3 pilar tampil; alias `/why`→`anf_why`; help Enterprise memuat why.
- Regresi baseline tetap hijau (syntax, 25/25, encode).

---

## v1.2.0 (Fitur Enterprise — 6 command berdampak besar, 2026-09-06)
**Tema: menambah fungsionalitas seimbang lintas ranah untuk membantu semua pekerjaan.**

### Fitur baru (Section 13 — Enterprise)
| Command | Fungsi | Ranah |
|---|---|---|
| `/gen` | AI-assisted code generation (panggil hermes/opencode, tanpa AI → pesan jelas) | Coding |
| `/task` | Orchestrator task di **tmux latar** — survive restart; `start/list/attach/kill` | Otomasi/riset |
| `/q` | Pencarian cepat grep dalam project (skip .git/node_modules/venv) | Produktivitas |
| `/gitx` | Git quick-ops harian: `s/a/c/l/b/p/d/x` | Git |
| `/envcard` | Ringkasan env & tools sekali lihat (OS/uptime/disk/mem/tools) | Monitoring |
| `/mvp` | Multi-version & branch mgmt: `tag/v/b/s/l` | Git/versioning |

### Verifikasi v1.2.0 (ad-hoc, mktemp)
- `zsh -n` → SYNTAX OK
- `test_suite.py` → **25/25** (regresi baseline hijau)
- Alias `/gen /task /q /gitx /envcard /mvp` → semua terdaftar ✅
- `/envcard` → sections OS/Disk/Mem + tools (git/tmux/docker/python3/node/hermes/opencode) ✅
- `/q` → grep keluar match ✅
- `/gitx s` → status git ✅
- `/task` tmux lifecycle: start+list+kill ✅ (survive restart confirmed)
- `/mvp v` → `ANF_VERSION=1.0.0` ✅
- `help` → kategori **Enterprise** tampil ✅
- Total fungsi: 97 → **103**

### Footnotes
- Ke-6 command dipilih dari preferensi user (seimbang, dampak besar, bukan 20-an).
- `gen`&`task`&`gitx`&`q`&`envcard`&`mvp` tersedia via launcher `anf <cmd>` NON-interaktif juga.

---

## v1.0.0 (Rebrand Enterprise + Research, 2026-09-06)
**Tema: AFUCKINGCO → ANF Research Shell. Struktur enterprise + fondasi penelitian.**

### Perubahan utama
- **Rebrand total:** semua identifier `afuckingco`/`AFUCKINGCO`/`_af_`/`_AF_` → `anf`/`ANF`/`_anf_`/`_ANF_` (manual, terverifikasi 0 leftover). Versi reset ke `1.0.0`.
- **Struktur enterprise/research baru** di `~/Documents/ANF-Research-Shell/`:
  - `code/` — script inti + test + `anfrc.dist` (template config)
  - `bin/anf` — **launcher CLI**: `anf <cmd> [args]` (command tunggal) atau `anf` (shell interaktif)
  - `research/` — `PAPER_OUTLINE.md` + `outputs/reproducibility_manifest.md`
  - `docs/`, `server/`, `packages/`
  - `install.sh` — installer enterprise (install launcher + script inti + config)
- **Launcher `bin/anf`** dengan resolusi lokasi berlapis (env `ANF_LIB` → lokasi install → project) → portabel/self-contained.
- **Config** `anfrc.dist` (prefix `ANF_`), dibaca saat launch.
- **README akademik** + **reproducibility manifest** (baseline verifiable).

### Verifikasi v1.0.0
- `zsh -n code/anf_research_shell.zsh` → **SYNTAX OK**
- `python3 code/test_suite.py` → **25/25 (100%)**
- `bin/anf encode hello` → `aGVsbG8=` (base64) ✅
- `bin/anf hash abc` → MD5 `90015098...`, SHA256 `ba7816bf...` ✅
- `bin/anf version` / `status` / `help` → jalan dari launcher ✅
- Alias pasca-source: `/help`→`anf_help`, `/status`→`anf_status`, `/c2-start`→`anf_c2_start` ✅
- Install portabel ke `/tmp/anf-install-test/` → `anf version` jalan (self-contained) ✅
- `.zshrc` di-update → `source ~/Documents/ANF-Research-Shell/code/anf_research_shell.zsh`

### Footnote
- Folder lama `.../zsh project/` dipertahankan (jejak v15 + archive). Tidak dihapus.
- Cache dir otomatis pindah ke `~/.cache/anf/` (rename var `ANF_CACHE_DIR`).
- TODO: inisialisasi git + tag, lisensi, CI, eksperimen paper §5.

---

## v15.0.1-RESEARCH (Hotfix /help + popup) — history pra-rebrand

### Bug Fixes (2026-09-06, setelah restart laptop)

| ID | Lokasi | Problem | Fix |
|----|--------|---------|-----|
| FIX-ALIAS-ORDER | Section 10, loop alias `/cmd` (baris ~1973) | Loop pembuat alias berjalan **sebelum** `afuckingco_help` didefinisikan (baris ~1980) → alias `/help` tidak pernah terbuat; `/help` error `zsh: no such file or directory: /help` padahal `/status` dll jalan | Pindahkan loop alias ke **setelah** fungsi `afuckingco_help` (sebelum Section 11). Kini semua 97 fungsi command sudah ada saat alias dibuat |
| FIX-POPUP-NL | Section 11, `_af_popup_render` | Baris header `' matches ─╮\n'` pakai single-quote biasa → `\n` ditampilkan **literal** (bukan newline); begitu juga `out+="│ ...\\n"` di double-quote → `\n` literal | Ganti ke `$'...'` (ANSI-C quoting) di header dan `"...\"$'\n'` di tiap baris match → newline asli |

### Verifikasi v15.0.1
- `zsh -n afuckingco_v15.zsh` → **SYNTAX_OK**
- Source di subshell → alias `/help -> afuckingco_help`, `/status -> afuckingco_status`, `/scan -> afuckingco_scan` ✅
- Unit-render popup (`cat -A`): tidak ada literal `\n`, newline asli di tiap baris ✅
- `test_suite.py` → **25/25 passed (100%)**

---

## v15.0.0-RESEARCH (Merge v12.8.7-FINAL → v14.0.0-RESEARCH)
**Tema: Unifikasi — Base v14 (riset/hardening) + Fitur Operasional v12**

### Strategi Merge (2026-09-06)
- **Base = v14.0.0-RESEARCH** (semua hardening dipertahankan):
  - C2 server v14 (subprocess.run + shlex + sandbox) — TIDAK ditimpa server v12
  - `panic` non-destruktif (`unset HISTFILE` + `fc -p /dev/null`) — TIDAK ditimpa
  - `suricata` if/else fix (parse error) — TIDAK ditimpa
  - ZLE popup if/else, hash tanpa eval, eval framework, GuardFall v2 metrics
- **+61 fungsi v12** yang hilang di v14 (file `afuckingco_v12.8.7-FINAL.zsh` diarsipkan)
- **3 override** (v12 lebih kaya, definisi terakhir menang): `autopwn` (nmap+msf+nuclei), `osint_email` (+hunter.io), `sysinfo` (laporan laptop lengkap)
- **Skip** bare-name wrappers v12 (`function katana/nuclei/ffuf/...`) — risiko shadowing binary

### Fitur Baru dari v12 (61 fungsi)
| Kategori | Fungsi |
|----------|--------|
| IP cache | `check-ip`, `clear-ip`, `cached_ip` |
| Targets | `targets add/list/remove/clear` |
| Config | `config`, `paths`, `version`, `install`, `update`, `log`, `selftest` |
| Recon | `dns`, `whois`, `quickrecon`, `subdomains-json` |
| Wireless | `wifisurvey`, `monitor`, `mac`, `pilgrims` |
| Network | `screenshot`, `proxy` |
| Utils | `uuid`, `random`, `epoch`, `clip` |
| Tools | `amass`, `gobuster`, `nikto`, `whatweb` |
| Integrations | `hermes`, `hermes-locate`, `hermes-set`, `github` |
| C2 ops | `c2-payload`, `c2-interact`, `c2-exfil`, `c2-decode` (server v14 tetap) |
| OSINT | `osint-phone`, `cloud-enum`, `wayback` |
| Exploit | `priv-esc`, `password-spray` |
| Pivot | `pivot-socks`, `port-forward`, `ssh-tunnel` |
| Defense | `honeypot`, `wazuh-agent` |
| Post-exploit | `persist`, `credentials`, `screenshot-all`, `clear-logs` |
| Lainnya | `playbook`, `ai-assist`, `ai-log` |

### Verifikasi v15
- `zsh -n afuckingco_v15.zsh` → SYNTAX_OK
- Source OK — `AFUCKINGCO_VERSION=15.0.0-RESEARCH`
- `test_suite.py` → 25/25 (tetap hijau, tak tersentuh)
- Selftest → **16/16 PASS** (termasuk check-ip network)
- Duplikat fungsi: hanya 3 override yang disengaja (autopwn/osint_email/sysinfo); tidak ada duplikat tak-sengaja; `function katana/nuclei/...` = 0
- Help 16 kategori menampilkan command baru

---

## v14.1.0-RESEARCH (Audit)
**Tema: Bug Fixes + Verifikasi Baseline**

### Bug Fixes (Audit 2026-09-06)

| ID | Lokasi | Problem | Fix |
|----|--------|---------|-----|
| FIX-PARSE | Section 12, `afuckingco_suricata` | `command -v ... && sudo suricata ... & \` lalu `\|\|` → **parse error zsh** (`zsh -n` gagal di baris 1300), script tidak bisa di-source | Refactor ke `if command -v; then ... & else ...; fi` — background hanya di command, chain `\|\|` dipisah |
| FIX-REPRO | `test_suite.py` Isolation Forest | Klaim "seed=42 hasilkan nilai sama" tapi dua run memakai state random awal berbeda → F1 beda (0.75 vs 0.70), **bukan test reproducibility yang valid** | Ganti jadi invariant test benar: dua run dengan `random.seed(42)` di-reset sebelum masing-masing `fit()` → prediksi harus identik (`preds_r1 == preds_r2`) |

### Verifikasi Baseline
- `zsh -n afuckingco_v14.zsh` → **SYNTAX_OK** (sebelum fix = parse error baris 1300)
- `source` script di subshell → OK, `/help` exit 0
- `test_suite.py` → **25/25 passed (100%)** (sebelumnya 24/24 — +1 test reproducibility baru)
- Smoke test runtime: `encode`/`decode`/`hash`/`status` semua benar (MD5 abc, SHA256 ba7816...)
- Audit konsistensi: 36 fungsi publik ↔ 34 slash command, semua mapping valid; `panic` non-destruktif (unset HISTFILE), `c2_start` subprocess.run+shlex+sandbox, ZLE popup if/else benar

---

## v14.0.0-RESEARCH (Current)

### Bug Fixes (Kritis)

| ID | Lokasi | Problem v13 | Fix v14 |
|----|--------|-------------|---------|
| FIX-C2 | Section 6, `server.py` | `os.popen(cmd).read()` — shell injection, no timeout | `subprocess.run()` + `shlex.split()` + timeout=15s + sandbox CWD |
| FIX-GF | Section 3, `_af_canonicalize_command` | `${IFS}` variant tidak terdeteksi | Tambah `${IFS}`, `${IFS:-}`, tab char ke IFS check |
| FIX-PANIC | Section 5, `afuckingco_panic` | `rm -f ~/.zsh_history` — destructive & irreversible | Ganti dengan `unset HISTFILE` + `fc -p /dev/null` saja |
| FIX-ZLE | Section 11, `_af_ki_accept` | `BUFFER=[[ ... ]] && ... || ...` — syntax error zsh | Gunakan `if/else` yang proper |

### New Features

#### GuardFall v2 [NEW-GF, NEW-GF-M, NEW-BENCH]
- **Unicode normalization**: Hapus full-width chars (ｒｍ→rm), zero-width chars (U+200B), null bytes
- **Expanded patterns**: env injection (`LD_PRELOAD`), path traversal (`../../../`), fork bomb (`:(){:|:&};:`)
- **Metrics tracking**: TP, FP, FN, TN → Precision, Recall, F1, Accuracy (per-session)
- **`/guardfall-metrics`**: Tampilkan & export JSON
- **`/benchmark-guardfall`**: Labeled dataset (12 ATTACK + 8 BENIGN) dengan evaluasi kuantitatif

#### Math/ML Enhanced [NEW-ENT, NEW-BEACON, NEW-ISO]
- **Entropy Bootstrap CI**: 95% Confidence Interval via 500 resamples
- **Threshold empiris**: Divalidasi via ROC sweep (optimal H≈6.0, F1=1.0 pada 400 sampel)
- **Beaconing Chi-Square**: Test H₀ uniformitas interval — H₀ ditolak → non-uniform → beaconing
- **Beaconing Autocorrelation R(1)**: Periodik tinggi → R(1) → 1.0
- **Isolation Forest**: Implementasi murni Python (tanpa scipy/sklearn) — Liu et al. (2008)
- **Z-Score dipertahankan** sebagai baseline perbandingan untuk paper

#### Evaluation Framework [EVAL-01, EVAL-02]
- **`/eval-entropy-roc`**: ROC sweep threshold 3.0–8.0, output CSV
- **`/eval-compare-ml`**: Z-Score vs Isolation Forest dengan export ke file
- **`/eval-export-audit`**: Audit log JSONL → CSV (pandas-ready)

#### C2 Improvements [NEW-C2LOG]
- **JSONL session logging**: Timestamp, client IP, command, blocked status, output length
- **`/c2-sessions`**: Tampilkan log dengan `jq` atau plaintext
- **SIGTERM graceful shutdown**: Server mati bersih via `kill -TERM`
- **Minimal ENV**: `PATH=/usr/bin:/bin:/usr/local/bin` saja — cegah env injection

#### Help Dikategorisasi [NEW-HELP]
- 9 kategori: Core, Recon, OPSEC, C2 Framework, Math/ML, Security Engine, Evaluation, Defense, Output

### Penambahan Commands
```
/c2-sessions         # Lihat C2 session log
/c2-zscore           # Z-Score baseline (untuk perbandingan paper)
/guardfall-metrics   # GuardFall TP/FP/F1
/eval-entropy-roc    # ROC CSV export
/eval-compare-ml     # ML comparison
/eval-export-audit   # Audit → CSV
```

### Test Suite
- `test_suite.py`: 24 unit tests, 6 modul
- 100% pass rate (24/24) — diverifikasi sebelum rilis

---

## v13.0.0-ULTIMATE (Previous)
- C2 framework: `os.popen()` (vulnerable)
- GuardFall: basic patterns, no metrics
- Entropy: hardcoded threshold tanpa justifikasi empiris
- Beaconing: jitter only, no statistical test
- ML: Z-Score only
- No evaluation framework
