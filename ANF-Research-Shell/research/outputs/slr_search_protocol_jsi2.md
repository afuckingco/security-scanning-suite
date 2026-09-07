# Protokol Pencarian SLR — JSI2 (Fondasi Matematis & Fisika ML)

**Tujuan:** artefak reproducibility komponen tinjauan sistematis manuskrip JSI2
("Fondasi Matematis Dan Fisika Machine Learning", OJS ID 869). Protokol ini
mendokumentasikan strategi pencarian, alur skrining, dan validasi bibliografi —
komponen non-numerik dari deliverable JSI2 (komponen numerik: eksperimen VAE,
lihat reproducibility_manifest.md §9).

## 1. Database & tanggal

- Database: **arXiv** (resmi, via API `export.arxiv.org`).
- Tanggal pencarian (per manuskrip §2.1): **6 September 2026**.
- Catatan reproduksi: jumlah hasil arXiv berubah seiring penambahan makalah baru —
  replikasi pada tanggal berbeda TIDAK dijamin menghasilkan hit count yang sama;
  klaim manuskrip terikat pada tanggal pencarian tersebut.

## 2. Strategi pencarian (Tabel 1 manuskrip)

| Kode | Query (arXiv) | Hasil (06-09-2026) |
|---|---|---|
| Q1 | `all:"measure theory" AND all:"machine learning"` | 56 |
| Q2 | `all:"energy-based models" AND all:"deep learning"` | 41 |
| Q3 | `all:"renormalization group" AND all:"deep learning"` | 33 |
| Q4 | `all:"denoising diffusion probabilistic"` | 748 |
| Q5 | `all:"score-based generative modeling"` | 292 |
| **Total** | | **1.170** |

Jumlah konsisten secara aritmetika: 56+41+33+748+292 = 1170.

## 3. Alur skrining (PRISMA-style)

```
1.170 teridentifikasi (5 strategi arXiv)
  → − duplikat antar-strategi & skrining judul/abstrak (relevansi 3 lapisan)
34 lolos skrining
  → − gagal verifikasi teks penuh / di luar cakupan
17 dianalisis (13 arXiv teks penuh terverifikasi + 3 artikel klasik
              + 1 buku teori ukuran)
```

Kriteria inklusi (manuskrip §2.2): (1) teori ukuran/probabilitas dalam konteks
ML/DL; (2) model berbasis energi atau turunannya; (3) model difusi atau
score-based generative models.
Kriteria eksklusi: duplikat antar-strategi; teks penuh tidak terverifikasi;
topik di luar tiga lapisan. Identitas berkas diverifikasi dari halaman pertama
(judul & penulis harus cocok dengan metadata yang dikutip).

## 4. Validasi bibliografi (anf bib)

Sumber: `submissions/jsi2/mendeley/jsi2_references.bib`

```
total entries : 16 (terhitung via regex ^@; sebenarnya 17 entri — lihat catatan bawah)
duplikat      : 0
tipe          : article=5, book=1, inproceedings=9, misc=1
baris mencurigakan: 0
```

**Hasil cek manual (2026-09-07):** selisih "16 vs 17" sebelumnya adalah **false
alarm** — semua 17 referensi ada (pemetaan 1:1 dengan urutan kemunculan manuskrip).
Penyebab hitungan 16: glitch format Mendeley — baris `}@inproceedings{kingma2014vae,`
menggabungkan kurung tutup entry `tao2011measure` dengan pembuka entry `kingma2014vae`
(Kingma & Welling 2014, ref [5]) tanpa newline, sehingga regex `^@` di `anf bib`
melewatkannya. ISBN dan isi entry valid; PDF ada di project
(`research/literature/jsi2_refs/kingma2014vae_1312.6114.pdf`).
**Perbaikan (saat paper tidak lagi frozen):** sisip newline sebelum
`@inproceedings{kingma2014vae,` → `anf bib` akan melaporkan 17/0/0.

✅ **Observasi lama sudah ter-resolve (2026-09-07):** tidak ada referensi yang
hilang — 17/17 lengkap; selisih hitungan murni glitch format (lihat catatan atas).

## 5. Komponen numerik (VAE)

Komponen validasi empiris SLR (VAE pada campuran 6 Gaussian) direproduksi
sebagai deliverable ANF — lihat reproducibility_manifest.md §9.