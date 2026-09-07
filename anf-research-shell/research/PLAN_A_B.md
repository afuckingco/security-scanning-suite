# PLAN — ANF Sesi Berikutnya (A + B)
**Status: SELESAI (ditandai 2026-09-07) — Plan A dieksekusi (DCA/JSI3 + JSI1 + JSI2 deliverables, `make verify` 24 gate) & Plan B (stabilkan; versi 1.6.1; infra enterprise §10 manifest). Dokumen ini arsip historis.**
**Dibuat:** 2026-09-06 (akhir sesi panjang; user minta /new untuk sub-tugas berikutnya)
**Konteks:** keputusan user setelah diskusi — A (jadikan harness riset untuk paper yang ada) + B (stabilkan, berhenti nambah fitur).

---

## A. Jadikan ANF harness riset untuk paper yang SUDAH ada

**Tujuan:** hasilkan artefak terukur (angka + manifest) yang bisa dilampirkan ke manuskrip riset yang sedang in-review (JSI2/JSI3/DCA) — bukan paper standalone baru.

**Langkah konkret (urut):**
1. Baca konteks riset: `~/Documents/Obsidian Vault/Workspace/Projects/Adversarial ML for IDS Validation via Red-Team Techniques/` — fokus DCA (submissions/jsi3, research/DCA_LEMMA_ANALYSIS_2026-09-07.md).
2. Pilih SATU eksperimen nyata (paling direkomendasikan: sweep α/m DCA yang sudah ada di `code/scripts/dca_sweep_demo.py`, dataset sintetik yang used in paper).
3. Bungkus dengan ANF:
   - `anf exp <nama>` → scaffold reproducible (seed.txt + env.txt + run.sh)
   - `anf mlbench <n>` → baseline deterministik → CSV research/outputs
   - `anf plot <csv>` → visualisasi → PNG
   - `anf sha <file>` → checksum untuk manifest
4. Kumpulkan hasil di `research/outputs/`, update `reproducibility_manifest.md` (versi + angka).
5. Sinkronkan ke manuskrip (JSI3/DCA) sebagai reproducibility deliverable — update bagian metode/referensi yang relevan.

**Kriteria selesai:** research/outputs berisi ≥2 artefak nyata (CSV + PNG + manifest) yang bisa dikutip, dan ber-trace ke eksperimen yang sudah ada di paper.

## B. Stabilkan — berhenti nambah fitur

**Tujuan:** ANF v1.6.x adalah batas fitur. Tidak ada command baru yang ditambahkan tanpa alasan kuat dari kebutuhan eksperimen A.

**Langkah:**
1. **Jangan tambah** command/fungsi baru kecuali diminta eksperimen A.
2. Rapikan yang ada:
   - Error handling sudah konsisten (csv/stat/plot/bib ramah) — verifikasi cepat sekali saja.
   - Audit kecil: adakah command yang outputnya masih aneh/kurang konsisten?
3. Polis dokumen (README sudah sinkron 1.6.1; cek PAPER_OUTLINE relevan).
4. Verifikasi ad-hoc SATU KALI (mktemp, hermes-verify- prefix, langsung hapus), lalu commit lokal (identity noreply, tanpa push).

**Kriteria selesai:** working tree bersih, satu commit terakhir, semua dokumentasi versi 1.6.1 konsisten.

---

## Aturan kerja sesi berikutnya (dari SOUL.md & skill)
- Hemat token: baca terbatas (grep dulu), batch panggilan, hindari loop verifikasi berulang.
- Verifikasi ad-hoc: script mktemp `/tmp/hermes-verify-*`, jalankan, HAPUS, lapor "ad-hoc, exit N".
- Commit lokal dengan identity: `83301093+afiqandico@users.noreply.github.com` — tanpa push.
- Bahasa pengantar: Bahasa Indonesia.
- Skill: `zsh-security-tooling-audit` memuat prosedur ANF lengkap (rename, launcher, pitfalls, konvensi).