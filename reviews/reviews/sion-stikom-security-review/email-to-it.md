# Email to STIKOM IT Support

> Template email untuk forward ke IT STIKOM Bali. Personalisasi [bracketed] fields sebelum kirim.

## Subject (pilih satu)

- **Opsi 1 (netral)**: Feedback SION — Saran Penambahan Security Header
- **Opsi 2 (langsung)**: Pengamatan SION — Konsistensi Security Header di Halaman Dinamis
- **Opsi 3 (kolaboratif)**: Beberapa Saran Perbaikan untuk SION (dari Mahasiswa)

Rekomendasi: **Opsi 1** — paling aman, tidak mengancam, tidak sensational.

## Body Email

```
Yth. Tim IT STIKOM Bali,

Perkenalkan, saya Afiq Andico, mahasiswa Program Studi Sistem Informasi.
Saya menulis untuk menyampaikan beberapa pengamatan ringan terkait
SION (sion.stikom-bali.ac.id) yang saya temukan beberapa hari terakhir.

LATAR BELAKANG
Saya kebetulan sedang belajar tentang web security (HTTP security headers
& best practice) untuk kebutuhan riset pribadi, dan saat menerapkan
pengetahuan tersebut ke SION yang sehari-hari saya gunakan, saya notice
ada beberapa hal yang mungkin bisa di-improve — khususnya soal
konsistensi security header di halaman yang di-render oleh aplikasi
dibanding halaman static.

PENEKANAN PENTING
Ini bukan laporan bug atau tuduhan apapun. SION secara keseluruhan sudah
punya fondasi keamanan yang baik:
- Cloudflare WAF aktif dan memblokir probing ke path sensitif
- HSTS aktif
- CSRF token pada form login
- Login menggunakan method POST (bukan GET)
- Cache-Control: no-store pada halaman login

Pengamatan ini murni untuk bahan evaluasi internal, dan semua bisa
diverifikasi tanpa akses khusus — cukup dengan curl atau browser DevTools.

RINGKASAN PENGAMATAN

1. Security header di halaman dinamis kurang lengkap
   Halaman login (dan kemungkinan halaman lain yang di-render oleh
   aplikasi) tidak memiliki beberapa header standar:
   - Content-Security-Policy
   - Referrer-Policy
   - X-Content-Type-Options
   - X-Frame-Options
   - Permissions-Policy
   Padahal static asset (misal: PDF tutorial) sudah memiliki header
   X-Frame-Options dan X-Content-Type-Options — terlihat seperti
   inkonsistensi konfigurasi di level web server.

2. Indikator framework CodeIgniter versi lama
   Beberapa indikator (meta description, nama CSRF token) menunjukkan
   kemungkinan penggunaan CodeIgniter 3, yang rilis patch terakhirnya
   sudah cukup lama. Worth dicek apakah masih dalam support window.

3. Detail minor
   - Form login menggunakan autocomplete="off" yang sebenarnya tidak
     efektif di browser modern (bisa rugikan UX)
   - CSRF token name masih default CodeIgniter

TINGKAT SEVERITY
Semua pengamatan di atas masuk kategori medium ke informational — tidak
ada yang critical. Tidak ada kerentanan yang bisa dieksploitasi langsung
dari pengamatan ini.

YANG TIDAK SAYA LAKUKAN
Agar jelas etika: saya hanya melakukan static analysis (cek HTTP
response & HTML inspection via curl). Saya TIDAK:
- Mencoba login dengan kredensial siapapun
- Melakukan brute force atau password guessing
- Mengirim request berbahaya
- Mengakses area authenticated

Saya menghormati privasi dan keamanan sistem, dan hanya melakukan
pengamatan pada public surface.

LAMPIRAN
Saya sudah siapkan catatan lebih detail (sekitar 13KB) yang berisi:
- Bukti pengamatan (HTTP response, HTML snippet)
- Penjelasan setiap temuan
- Rekomendasi fix spesifik (snippet nginx/Apache/CodeIgniter yang bisa
  langsung di-copy-paste)
- Cara verifikasi independen (semua reproducible)
- Daftar hal yang perlu dicek internal oleh Tim IT

Catatan lengkap tersedia dalam dua format:
1. Markdown (.md) — terlampir sebagai Report.md
2. Google Docs (siap share) — link: [ISI_LINK_JIKA_ADA]

KONTAK
Kalau Tim IT berkenan berdiskusi atau butuh klarifikasi, saya terbuka:
- Email: afiqandico13@gmail.com

Saya sangat berharap feedback ini bermanfaat, dan SION bisa makin aman
untuk kita semua mahasiswa dan civitas akademika.

Terima kasih sudah membaca dan mempertimbangkan.

Salam hormat,
Afiq Andico
Mahasiswa Program Studi Sistem Informasi
STIKOM Bali
NIM: [ISI_NIM]
Kontak: afiqandico13@gmail.com
```

## Tips Tambahan

- **Waktu kirim**: jangan tengah malam. Kirim pagi (08-10) atau siang (13-15) hari kerja
- **Follow-up**: kalau 1 minggu gak ada respons, boleh WA gentle ping
- **Ekspektasi**: tim IT akademik biasanya lambat respond — jangan kecewa
- **Positif**: kalau IT merespons, tawarin diskusi / share full report

## After Sending

- Catat tanggal kirim di `Report.md` (tambah section "Follow-up log")
- Update repo ini kalau ada respons / follow-up
- Kalau IT fix beberapa item, bisa bikin blog post atau write-up
