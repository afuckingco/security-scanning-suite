# Paper Outline — ANF Research Shell
**Draft rencana manuskrip untuk publikasi (Q1/Sinta).**
Status: OUTLINE — belum ada eksperimen formal sendiri (baseline tool v1.6.1; evaluasi §5 belum dieksekusi).

---

## Judul (draft)
**"ANF: an Open, Reproducible Zsh Framework for Adversarial Evasion Research in Intrusion Detection"**
Ataf, FP (false positive) terkendali + evaluasi terintegrasi untuk riset evasion.

## Abstrak (draft 3 kalimat)
1. Masalah: riset adversarial ML untuk IDS sering tidak reproducible — evaluasi tidak terstandar, threshold tersembunyi, metrik (F1/ROC) dihitung inkonsisten.
2. Kontribusi: ANF, framework bash/zsh terbuka yang membungkus *evasion traffic generator*, deteksi entropi, Isolation Forest, GuardFall pattern-matching, dan framework evaluasi ROC → satu CLI yang reproducible.
3. Hasil/bukti: 25 test deterministik (seed-42), smoke test verifiable, install mandiri via installer — baseline untuk eksperimen lanjutan.

## 1. Pendahuluan
- Motivasi: reproduksibilitas riset keamanan (gap metodologis).
- Positioning: tool riset (bukan produk komersial), berorientasi purple-team.

## 2. Latar Belakang & Work Terkait
- Adversarial evasion di NIDS (referensi: Apruzzese et al.; Shehaby & Matrawy — sesuai kontak arXiv user).
- DCA / DRL traffic generation (menghubungkan ke project Adversarial ML user).
- Framework evaluasi: ROC-AUC, F1, bootstrap CI.
- Gap: tidak ada framework zsh terbuka, reproducible, terintegrasi.

## 3. Arsitektur & Desain
- **Lapisan 1 (Deteksi):** entropi Shannon + bootstrap CI; ROC threshold optimal.
- **Lapisan 2 (ML):** Isolation Forest anomaly detection (seed-reproducible).
- **Lapisan 3 (Pattern):** GuardFall v2 — regex pattern matching (unicode-normalized), TP/FP/FN/TN, F1.
- **Lapisan 4 (Eval):** `eval-entropy-roc`, `eval-compare-ml`, `eval-export-audit`.
- **Lapisan 5 (C2/red-team ops):** C2 server hardening (subprocess.run + shlex + sandbox), beaconing math (jitter, autocorrelation, chi-square), OPSEC (panic non-destruktif).
- **CLI & UX:** ZLE popup autocomplete, alias `/cmd`, launcher `anf`.

## 4. Metodologi & Reproduksibilitas
- Baseline verifikasi (manifest): `zsh -n`, 25 test, smoke deterministic.
- Determinisme: `random.seed(42)` di-reset per run.
- Install mandiri (install.sh) → artefak tertelusur.

## 5. Evaluasi (RENCANA — perlu eksekusi)
- [ ] Benchmark GuardFall vs baseline (sudah ada `benchmark-guardfall`: CSV ke `research/outputs/`).
- [ ] ROC threshold sweep → tabel + figure.
- [ ] Isolation Forest reproducibility (2 run seed-42 identik).
- [ ] Case study: evidence traffic genuine vs generated.

## 6. Batasan & Work Masa Depan
- Tool untuk riset, bukan tool produksi; kekuatan ada di standarisasi & keterbukaan.
- Extensi: DCA integration, larger benchmark datasets.
- Publikasi pendamping.

## 7. Kesimpulan
- Standarisasi evaluasi evasion; framework reproducible; fondasi untuk riset lanjut.

---

## Skenario publikasi (konservatif & realistis)
- **Realistis (Q1/Sinta):** butuh eksperimen nyata (bagian §5) + dataset publik (CICIDS/UNSW). Strategi: jadikan *artefak pendamping* dari paper adversarial-ML user yang sudah ada (JSI/DCA), bukan paper standalone dulu.
- **Default lebih mudah:** lampirkan framework sebagai *reproducibility deliverable* pada manuskrip JSI3/DCA yang sudah masuk review — kurang usaha, nilai ilmiah jelas.

## Kontributor & AI disclosure
- AI (Hermes, model DeepSeek V4 Flash) membantu implementasi & penulisan — disclosure wajib sesuai kebijakan jurnal.
- Penulis utama: Afiq Andico Pangimpian (Independent Researcher).
