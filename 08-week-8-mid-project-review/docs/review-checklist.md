# Checklist Mid Project Review

## Audit branch dan commit

Audit dilakukan pada riwayat `origin/main` saat menyiapkan branch fitur. Tiga
pesan berikut adalah contoh nyata yang dapat diperjelas; tabel ini hanya
simulasi pesan yang lebih deskriptif dan **tidak mengubah riwayat Git**.

| Pesan lama | Usulan pesan yang lebih jelas | Alasan |
|---|---|---|
| `menambahkan di readme` | `docs(readme): tambahkan navigasi tugas mingguan` | Menjelaskan tipe perubahan dan lokasi dokumentasi. |
| `menambahkan di readme` | `docs(readme): perbarui navigasi tugas mingguan` | Membuat perubahan kedua dapat dibedakan dari commit pertama. |
| `praktikum week 7` | `docs(week7): dokumentasikan hasil praktikum clean architecture` | Menyebut cakupan dan hasil yang dicatat. |

Jangan amend/rewrite commit lama hanya untuk latihan ini. Branch panjang umur
dan commit langsung ke `main` perlu dicek kembali sebelum mengirim PR.

## Pemeriksaan sebelum PR

- [x] Branch `develop` dibuat dari `origin/main` dan sudah dipush; isinya
  saat ini Week 1–7.
- [x] Branch kerja `feature/08-week-8-mid-project-review` dibuat dari `develop`.
- [x] Commit `dc39f06` sudah dipush pada branch fitur; branch tersebut
  memuat Week 1–8.
- [x] Satu project Week 7 dipertahankan sebagai fokus review Week 8.
- [x] Masukan review teknis dengan gaya reviewer sejawat dicatat untuk dibahas
  pada PR; persetujuan PR GitHub belum ada.
- [ ] Buat issue Week 8; catat nomor dan tautannya.
- [ ] Buat PR dengan base `develop` dan compare
  `feature/08-week-8-mid-project-review`. Screenshot perbandingan saat ini
  memilih `main`; ganti base sebelum membuat PR.
- [ ] Minta reviewer yang ditugaskan memeriksa PR di GitHub dan mencatat
  keputusan; masukan teknis di bawah bukan status approve GitHub.
- [ ] Setelah PR ditinjau dan diputuskan, merge ke `develop` agar `develop`
  memuat Week 1–8. Jangan merge langsung ke `main`.
- [ ] Untuk Week 9–16, mulai tiap branch fitur dari `develop` terbaru dan
  merge PR yang sudah disetujui agar `develop` tetap kumulatif.
- [x] `flutter analyze`, `dart format`, dan `flutter test` hijau; hasil ada di
  [`verification.md`](verification.md).
- [ ] Tindak lanjuti temuan yang disetujui dan minta re-review sebelum merge.
- [ ] Merge via review dan verifikasi issue tertutup; hapus branch remote setelah
  merge.
- [ ] Perbarui status README dengan tautan issue/PR dan hasil review yang nyata.

## Catatan review teknis untuk PR

| Kategori | Temuan/tautan komentar | Tindak lanjut | Status |
|---|---|---|---|
| Kebenaran/state | Kegagalan add/edit/delete membuat state Notes menjadi error dan menyembunyikan daftar. | Pertahankan data terakhir, tampilkan pesan spesifik, dan uji repository failure. | Perlu perubahan/keputusan sebelum merge |
| Test | Belum ada widget test untuk judul berisi spasi saja; validator memeriksa `trim().isEmpty`. | Tambahkan test whitespace sebagai regresi. | Saran |
| Arsitektur | Provider Notes mengimpor implementasi repository untuk composition root. | Domain tetap bebas driver; pemindahan wiring tidak diperlukan. | Tidak perlu perubahan |
| Cache Posts | Test menunjukkan kegagalan refresh jaringan mempertahankan cache dan meneruskan failure. | Pertahankan perilaku saat refactor. | Terverifikasi |
| Keterbacaan/routing | Prompt menyebut GoRouter, sedangkan aplikasi memakai Navigator; UI Notes juga memuat dialog dan tile privat dalam satu file. | Tidak migrasi router tanpa kebutuhan; pemisahan widget dapat dipertimbangkan bila file terus tumbuh. | Saran opsional |

Catatan ini adalah masukan teknis untuk dibahas pada PR. PR Week 8 belum dibuat,
sehingga belum ada keputusan approve/request changes atau merge di GitHub.
