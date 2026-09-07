# NOTICE — Authorship & Attribusi

**ANF Research Shell** (Integrated & Reproducible Research Workbench)

## Penulis
- **Afiq Andico Pangimpian** (Independent Researcher) — satu-satunya penulis.

## Pengembangan & AI disclosure
- Seluruh kode (zsh, Python, shell), dokumentasi, eksperimen, dan artefak
  reproducibility di repositori ini **ditulis dan dikerjakan sendiri oleh penulis**
  dengan bantuan asisten AI (Hermes, model DeepSeek V4 Flash) sebagai alat
  pengembangan — sesuai kebijakan AI disclosure pada README.
- Tidak ada kode atau konten pihak ketiga yang disalin ke dalam repositori ini;
  script eksperimen yang di-vendor ke `research/outputs/exp_*/` adalah karya
  penulis dari proyek riset pribadi (disalin verbatim, sha256 tercatat di
  `research/outputs/reproducibility_manifest.md`).

## Copyright
- Kode dilisensikan **MIT** (lihat `LICENSE`). Karena seluruh konten ditulis
  sendiri, tidak ada klaim hak cipta pihak ketiga atas materinya.
- Data/dokumen riset: proposal CC-BY (menyusul bila diperlukan).

## Pernyataan kemandirian (standalone)
- Repositori ini **berdiri sendiri**: untuk membangun dan memverifikasi seluruh
  deliverable cukup `make setup` (venv + dependensi ter-pin) lalu `make verify`,
  tanpa bergantung pada repositori, akun, atau jalur berkas di luar repositori.