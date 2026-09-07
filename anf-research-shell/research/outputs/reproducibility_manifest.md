# ANF Research Shell — Reproducibility Manifest

**Project:** ANF Research Shell (v1.0 → v1.6.1)
**Tanggal manifest:** 2026-09-07
**Status:** DRAFT — baseline v1.0.0; fitur enterprise v1.2.0; research suite v1.3.0; researcher workflow v1.5.0; focus research v1.6.0; **v1.6.1 cyber modules diarsipkan**; **deliverable DCA (JSI3) 2026-09-07**.

## 1. Identitas artefak
| Field | Nilai |
|---|---|
| Nama | ANF Research Shell |
| Versi baseline | **1.6.1** (Integrated & Reproducible Research Workbench — fokus science/math/CS; cyber tidak dipromosikan) |
| Bahasa inti | zsh (>= 5.0), Python 3 (venv riset: torch/sklearn/numpy/matplotlib/pandas/scipy/sympy) |
| Lisensi | MIT (lihat `LICENSE`) |
| Repo | `https://github.com/afiqandico/security-lab` → `anf-research-shell/` (public; monorepo; lokal: `/home/afiq/Documents/ANF-Research-Shell/`) |
| Jumlah fungsi inti | 64 (119 → 64 setelah modul cyber operasional diarsipkan; arsip LOKAL `~/Documents/Archive/ANF-cyber-modules-v1.6/` — tidak ikut repo publik) |

## 2. Cara reproduksi baseline
```bash
# 1. Cek syntax script inti
zsh -n code/anf_research_shell.zsh          # MUST: SYNTAX OK

# 2. Jalankan test suite (modul Python: entropy, ROC, beaconing, GuardFall, C2)
python3 code/test_suite.py                  # MUST: 25/25 pass

# 3. Smoke test runtime (output nyata, deterministic)
bin/anf encode hello        # -> aGVsbG8= (base64)
bin/anf hash abc            # -> MD5 900150983cd24fb0d6963f7d28e17f72
                            #    SHA256 ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad

# 4. Alias /cmd tersedia setelah source (pastikan loop alias jalan)
#    /help -> anf_help, /status -> anf_status, /scan -> anf_scan
```

## 3. Hasil verifikasi baseline (2026-09-06)
- `zsh -n` → SYNTAX OK
- `test_suite.py` → **25/25 (100%)**
- `bin/anf version` → 1.0.0
- `bin/anf encode hello` → `aGVsbG8=`
- `bin/anf hash abc` → MD5 `90015098...`, SHA256 `ba7816bf...`
- Alias pasca-source: `/help`, `/status`, `/scan` → fungsi `anf_*` ✅

## 4. Lingkungan reproduksi
| Komponen | Versi | Catatan |
|---|---|---|
| OS | Linux (kernel 7.0.0-31-generic) | host saat manifest |
| zsh | >= 5.0 (dicek `is-at-least 5.0`) | |
| Python | 3.x | modul ML/eval |
| numpy | tersedia | GuardFall/entropy tidak wajib numpy (pure stdlib) |

*Catatan determinisme: entropy/ROC/GuardFall memakai `random.seed(42)` — lihat skill
`zsh-security-tooling-audit` §Test reproducibility: reset seed sebelum SETIAP run yang dibandingkan.*

## 5. Jelajah artefak
```
ANF-Research-Shell/
├── bin/anf                  # launcher CLI (interaktif / command tunggal)
├── code/anf_research_shell.zsh  # script inti (64 fungsi)
├── code/test_suite.py       # test suite Python (25 test)
├── code/anfrc.dist          # template konfigurasi
├── docs/CHANGELOG.md        # riwayat versi
├── research/                # paper outline, analisis, artifact
│   └── outputs/             # hasil eksperimen (json/csv/png)
├── server/                  # komponen server C2/eval (jika diperluas)
├── packages/                # sub-package modular (future)
└── install.sh               # installer enterprise
```

## 6. TODO reproducibility
- [x] Tambahkan git repo + tag v1.0.0 (agar hash artefak tertelusur) — repo git aktif; tag versi dipertimbangkan saat rilis.
- [x] Pin versi numpy/python di requirements.txt — deliverable JSI1: `research/outputs/exp_mini_soc_detector_20260907_144056/requirements.txt` (numpy 2.5.2, xgboost 3.4.1, psutil 7.2.2, scapy 2.7.0, matplotlib 3.11.1; dikembangkan di Python 3.14.4).
- [x] Buat `make test` / CI pipeline yang menjalankan langkah 2.1–2.3 — `Makefile` + `scripts/verify_repro.sh` (`make verify` / `make test`): baseline ANF + regenerasi deliverable JSI1 di sandbox + cek hash vs manifest (lihat §8.5).
- [ ] Set lisensi (proposal: MIT untuk kode, CC-BY untuk dokumen) — **MIT sudah ditetapkan** (file `LICENSE`, 2026); CC-BY untuk dokumen menyusul bila perlu.

## 7. Deliverable riset terpakai — eksperimen DCA (JSI3, bukti H5) [2026-09-07]

**Tujuan:** bungkus eksperimen DCA (sweep α, aturan finite-memory m=1: `W_{k+1}=1+α·1_{R_k<0}`)
yang sudah ada di manuskrip JSI3 (ID OJS 870) sebagai artefak reproducible ANF.

### 7.1 Reproduksi (satu perintah)
```bash
# Scaffold eksperimen berisi seed.txt + env.txt + run.sh + salinan script asli
bin/anf exp dca_sweep_alpha_m
# Jalankan (deterministik, seed 42; ~8 dtk di host ini):
research/outputs/exp_dca_sweep_alpha_m_20260907_005822/run.sh
```

Script asli: `code/scripts/dca_sweep_demo.py` (project "Adversarial ML for IDS Validation via
Red-Team Techniques") — disalin TIDAK dimodifikasi; sha256
`b1385290c5bd8027999d76bd1821fb11553f95aee9567b91749cd483ce43068f`.

### 7.2 Artefak + checksum
| File | sha256 (awal 16) | Keterangan |
|---|---|---|
| `dca_sweep_mc.json` | `6aa7752fa1aa3120` | hasil numerik (seed 42, MC 10⁶, 120 langkah, G=600) |
| `dca_sweep_mc.csv` | `f6211e0e2c6d9da5` | tabel ringkas per α (W1 + qgap) untuk sitasi |
| `dca_sweep_mc.png` | `b2770991c376439a` | bar chart W1 naif vs 2-state per α |
| `dca_sweep_demo.py` (scaffold) | `b1385290c5bd8027` | salinan source DCA di scaffold (verbatim) |
| `exp_dca_sweep_alpha_m_20260907_005822/` | — | scaffold lengkap (seed/env/run.sh/source) |

### 7.3 Hasil (identik dengan artefak project — determinisme terverifikasi 2× run)
| α | W1 rekursi 1-d naif | W1 rekursi 2-state | qgap (q10/q50/q90) |
|---|---|---|---|
| 0.0 | 0.00971 | 0.00971 | −0.434 / −1.134 / −6.292 |
| 0.5 | 0.01921 | 0.01007 | −0.573 / −1.468 / −8.064 |
| 1.0 | 0.02572 | 0.00972 | −0.721 / −1.688 / −9.062 |

**Arti (per DCA_LEMMA_ANALYSIS):** rekursi 1-d naif (kernel rata-rata salah) GAGAL untuk α>0
(W1 naik dengan α); rekursi 2-state benar (W1 ≈ 0.01 konstan, setara α=0) — konsisten dengan
lemma one-state closure: aturan `1_{R_k<0}` tidak satu-state, butuh state `(y,z)`.

### 7.4 Trace ke manuskrip
- Manuskrip: `submissions/jsi3/` (project Adversarial-ML) — eksperimen no.3 (bukti H5).
- Catatan metodologi + jebakan: `research/DCA_LEMMA_ANALYSIS_2026-09-07.md` §Bukti empiris.
- Status: JSI3 sudah disubmit OJS (ID 870) — artefak ini cadangan untuk revisi/response-to-reviewer.

## 8. Deliverable riset — detektor ML mini-SOC (JSI1, bukti evaluasi detector) [2026-09-07]

**Tujuan:** bungkus eksperimen pelatihan detektor ML mini-SOC (JSI1, OJS 3747-1) — 12.000
sampel sintetis per-paket (6.000 benign / 6.000 anomali), XGBoost 200 trees, seed 42 — sebagai
artefak reproducible ANF.

### 8.1 Reproduksi (satu perintah)
```bash
# Scaffold eksperimen (seed.txt + env.txt + run.sh + salinan script asli + build_artifact.py)
bin/anf exp mini_soc_detector
# Jalankan (deterministik, seed 42; ~8 dtk; interpreter di-resolve otomatis:
# $PYTHON → .venv/ repo-local → $HOME/venv → python3; buat .venv dulu via make setup):
research/outputs/exp_mini_soc_detector_20260907_144056/run.sh
# Bangun artefak CSV/JSON/PNG (path hasil regenerasi WAJIB argumen — repo berdiri sendiri):
.venv/bin/python research/outputs/exp_mini_soc_detector_20260907_144056/build_artifact.py <path/detector_metrics.json>
```

Script asli: `code/mini-soc-enterprise-arch/ml_detector/train_detector_real.py` (project
"Adversarial ML for IDS Validation via Red-Team Techniques") — disalin TIDAK dimodifikasi;
sha256 `06e747cc873eaab5b4c53d645b6c654447b5370bbcc10a5990cd64e7ef528fc9`.

### 8.2 Artefak + checksum
| File | sha256 (awal 16) | Keterangan |
|---|---|---|
| `mini_soc_detector_metrics.json` | `131474f2a19be30a` | metrik + provenance (seed 42, 12.000 sampel) |
| `mini_soc_detector_metrics.csv` | `1fa010db8389c0b7` | tabel ringkas 4 metrik untuk sitasi |
| `mini_soc_detector_metrics.png` | `bd542d7cffa4a96e` | bar chart metrik holdout (skala 0.98–1.00) |
| `exp_mini_soc_detector_20260907_144056/` | — | scaffold lengkap (seed/env/run.sh/source/build_artifact) |

### 8.3 Hasil (identik dengan manuskrip — determinisme terverifikasi 2× run byte-identical)
| Metrik | Nilai | Manuskrip JSI1 |
|---|---|---|
| Akurasi | 0.997083 | 0.9971 |
| Presisi | 0.999163 | 0.9992 |
| Recall | 0.995000 | 0.9950 |
| AUC | 0.999458 | 0.9995 |
| n_trees / n_splits | 200 / 2375 | (audit non-degenerate) |

Determinisme: run dari salinan scaffold + run script asli → keempat file output
(`detector_metrics.json` `db1fc8d677221668`, `xgboost_model.json` `1fe6e4bf570ef8f1`,
`feature_names.json` `4c5c6f64d6d60080`, `norm_params.json` `a3be1138d81d99b8`)
byte-identical dengan commit; git status proyek bersih.

### 8.4 Trace ke manuskrip
- Manuskrip: `submissions/jsi/` (JSI1) — arsitektur mini-SOC 8 layanan; angka evaluasi detektor
  (akurasi 0,9971; presisi 0,9992; recall 0,9950; AUC 0,9995) persis cocok.
- Status: JSI1 SUBMITTED OJS (ID 3747-1) — artefak ini cadangan untuk revisi/response-to-reviewer.
- Catatan: `synthetic_train.csv` di repo proyek bukan output script ini (dataset dibangkitkan
  in-memory via scapy dari aturan domain paket, seed 42).

### 8.5 Pemakaian mandiri (clone → make verify) [2026-09-07]
```bash
git clone https://github.com/afiqandico/security-lab && cd security-lab/anf-research-shell
make setup     # python3 -m venv .venv && pip install -r requirements.txt (agregat, ter-pin)
make verify    # alias: make test
```
`make verify` menjalankan: (A) baseline ANF — `zsh -n`, `test_suite.py` 25/25, smoke `bin/anf hash abc`;
(B) deliverable JSI1 — training di-SANDBOX `mktemp` yang meniru layout proyek
(`code/mini-soc-enterprise-arch/ml_detector/`) sehingga `Path(__file__).parents[3]` resolve
benar TANPA menulis polusi ke repo; lalu cek: sha salinan script == manifest, nilai ilmiah
regenerasi == manuskrip, sha `detector_metrics.json` byte-identical, sha CSV/JSON artefak ==
manifest, PNG dihasilkan. (C) deliverable JSI2 — VAE dijalankan di sandbox (script menulis
relatif-cwd), cek nilai ilmiah == manuskrip, sha JSON/CSV byte-identical, PNG dihasilkan.
Sandbox dihapus otomatis (trap EXIT); interpreter runtime di-resolve
otomatis (`$PYTHON` → kandidat lokal → `python3`) dengan kartu deps numpy+xgboost+psutil+scapy
(JSI1) / torch+numpy+matplotlib (JSI2);
artefak memakai interpreter ber-matplotlib. Exit 0 = semua gate lulus.

Verifikasi aktual 2026-09-07: `make verify` → PASS 25 / FAIL 0 / SKIP 0
(A baseline + B JSI1 + C JSI2 + D JSI3/DCA; 2 WARN pada kolom timing DCA — lihat §7.3).

## 9. Deliverable riset — validasi empiris VAE (JSI2, komponen numerik SLR) [2026-09-07]

**Tujuan:** bungkus eksperimen validasi empiris JSI2 — pelatihan *variational
autoencoder* (VAE) pada campuran 6 Gaussian 2D, 120 epoch, Adam lr=1e-3, seed 42 —
sebagai artefak reproducible ANF (bukti lapisan 2: mekanika statistik → variational
inference). Komponen non-numerik SLR (protokol pencarian) didokumentasikan di
`research/outputs/slr_search_protocol_jsi2.md`.

### 9.1 Reproduksi (satu perintah)
```bash
# Scaffold eksperimen (seed.txt + env.txt + run.sh + salinan script asli + build_artifact.py)
bin/anf exp jsi2_vae
# Jalankan (deterministik, seed 42; ~8 dtk di host ini; sandbox tmp, hasil ke research/outputs/):
research/outputs/exp_jsi2_vae_20260907_152636/run.sh
# Bangun CSV ringkas untuk sitasi (dari jsi2_vae_exp.json regenerasi):
.venv/bin/python research/outputs/exp_jsi2_vae_20260907_152636/build_artifact.py
```

Script asli: `code/scripts/run_vae_experiment.py` (project "Adversarial ML for IDS
Validation via Red-Team Techniques") — disalin TIDAK dimodifikasi; sha256
`124ceda2927e0f3499d2111c3ba640cc65c1b011b611ac58f805c6e0dd64701e`.

### 9.2 Artefak + checksum
| File | sha256 (awal 16) | Keterangan |
|---|---|---|
| `run_vae_experiment.py` | `124ceda2927e0f34` | salinan source di scaffold (verbatim) |
| `jsi2_vae_exp.json` | `0639f4f681a50b79` | metrik eksperimen (format asli script; byte-identical dgn artefak proyek) |
| `jsi2_vae_metrics.csv` | `80cb334007470988` | tabel ringkas (elbo/recon/kl/w2) untuk sitasi |
| `jsi2_vae_loss.png` | `2101e5f80067103e` | fig: kurva objektif (-ELBO) + data vs sampel VAE (dpi 300) |
| `research/outputs/slr_search_protocol_jsi2.md` | — | protokol pencarian SLR (query, alur 1170→34→17, validasi .bib) |

### 9.3 Hasil (identik dengan manuskrip — determinisme terverifikasi 2× run byte-identical)
| Metrik | Nilai | Manuskrip JSI2 (Abstrak) |
|---|---|---|
| Objektif awal (ep 0, -ELBO) | 10.1109 | "dari 10,11" |
| Objektif akhir (ep 120, -ELBO) | 2.7489 | "menjadi 2,75" |
| Kesalahan rekonstruksi | 0.3546 | 0,355 |
| KL akhir | 2.008 | — |
| Jarak Wasserstein-2 (approx) | 0.0999 | 0,100 |

Determinisme: 2 run (run.sh sandbox) → `jsi2_vae_exp.json` sha `0639f4f681a50b79`
dan `jsi2_vae_loss.png` sha `2101e5f80067103e` byte-identical di mesin pengembang;
JSON juga byte-identical dengan `research/outputs/jsi2_vae_exp.json` di repo proyek.
Lintas mesin (CI): nilai ilmiah stabil dalam 1e-3, sha dapat berubah bit terakhir
(lihat §10.3).

### 9.4 Trace ke manuskrip
- Manuskrip: `submissions/jsi2/` (JSI2, OJS ID 869) — Bagian 7 (validasi empiris);
  gambar `figures/fig2_vae_loss.png` di manuskrip = output script ini.
- Status: JSI2 SUBMITTED OJS (ID 869, MULFU 5%) — artefak cadangan untuk revisi.
- Validasi bibliografi (komponen SLR): `anf bib mendeley/jsi2_references.bib` → 16
  entri terhitung, 0 duplikat; **cek manual 2026-09-07: 17 entri lengkap** — hitungan
  16 hanya karena glitch format Mendeley (`}@inproceedings{kingma2014vae` tanpa newline,
  regex `^@` melewatkannya). Referensi [5] Kingma & Welling 2014 valid; fix saat paper
  tidak frozen — lihat `slr_search_protocol_jsi2.md` §4.

## 10. Infra reproducibility & enterprise [2026-09-07]

Status: **enterprise-ready** — verifikasi satu perintah utk SEMUA deliverable, CI,
dependensi ter-pin, lisensi.

### 10.1 Onboarding (klon → verifikasi)
```bash
git clone https://github.com/afiqandico/security-lab && cd security-lab/anf-research-shell
make setup     # python3 -m venv .venv && pip install -r requirements.txt (agregat)
make verify    # A baseline + B JSI1 + C JSI2 + D JSI3 — sandbox, hash vs manifest
```

### 10.2 Komponen
| Komponen | Path | Status |
|---|---|---|
| verifikasi agregat | `scripts/verify_repro.sh` + `Makefile` (`make verify`/`test`/`setup`) | ✅ 25 gate, 0 fail — hijau di CI GitHub Actions (2026-09-07) |
| requirements pin (agregat) | `requirements.txt` (xgboost 3.4.1, psutil 7.2.2, scapy 2.7.0, torch 2.13.0, scipy 1.18.0, numpy 2.5.2, matplotlib 3.11.1) | ✅ |
| requirements per-scaffold | `research/outputs/exp_*/requirements.txt` | ✅ JSI1, JSI2 |
| CI GitHub Actions | `.github/workflows/ci.yml` (ubuntu, py 3.14, make verify) | ✅ hijau (PASS 25/0/0, run 2026-09-07T08:45) |
| lisensi kode | `LICENSE` (MIT, 2026) | ✅ |
| authorship & standalone | `NOTICE.md` (author, AI disclosure, no third-party code) | ✅ |
| protokol SLR | `research/outputs/slr_search_protocol_jsi2.md` | ✅ |

### 10.3 Catatan gate & bukti standalone
JSON/CSV DCA memuat kolom `*_cost_s` (wall-clock timing) → sha byte TIDAK stabil
antar run. Gate DCA = (a) nilai ilmiah W1/qgap STRICT, (b) PNG byte-deterministik
STRICT di env sama, (c) sha JSON/CSV → **WARN** bukan FAIL. Ini desain, bukan bug
(lihat §7.3 + skill zsh-security-tooling-audit §DCA).

**Standalone terbukti (2026-09-07):** `make setup` di mesin bersih → `.venv` dengan
requirements ter-pin; `make verify` dijalankan dengan `HOME` kosong + `PATH` minimal
+ `PYTHON=.venv/bin/python` (mensimulasikan mesin asing tanpa venv lain, tanpa
proyek eksternal, tanpa path Obsidian) → **PASS 25 / FAIL 0 / SKIP 0**. Repositori
berdiri sendiri; deps: numpy 2.5.2, xgboost 3.4.1, scikit-learn 1.9.0, psutil
7.2.2, scapy 2.7.0, torch 2.13.0+cpu (index CPU PyTorch), scipy 1.18.0,
matplotlib 3.11.1.

**Gate lintas-mesin (CI GitHub Actions, 2026-09-07):**
- JSI1 (XGBoost): nilai + sha byte-identical STRICT lintas mesin ✅ (terbukti CI).
- JSI2 (torch CPU): float 4-desimal dapat beda bit terakhir lintas mesin (thread/
  BLAS; CI: 2-4e-4). Gate = nilai ilmiah toleransi 1e-3 STRICT; json/csv sha → WARN.
- JSI3 (DCA): nilai W1/qgap toleransi STRICT; PNG byte STRICT; json/csv sha → WARN
  (kolom timing + float). Semua masih cocok angka manuskrip (2,75 / 0,355 / 0,100).
