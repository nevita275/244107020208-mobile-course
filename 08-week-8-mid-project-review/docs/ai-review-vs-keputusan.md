# AI Review vs Keputusan

## Prompt

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

Prompt menyebut GoRouter sebagai konteks, tetapi project menggunakan
Navigator. Ini bukan bug dan tidak memerlukan migrasi tanpa kebutuhan produk.

## Batas review

Review AI awal dilakukan atas permintaan author terhadap kode Week 8. Review
tersebut bukan peer review manusia dan tidak menghasilkan approval GitHub.
PR #2 menggunakan `develop` sebagai base dan branch
`feature/08-week-8-mid-project-review` sebagai compare; PR itu telah di-merge
ke `develop` pada 29 Oktober 2026.

Reviewer manusia kemudian meninggalkan komentar pada PR #2 setelah merge.
GitHub tidak mencatat formal review sebelum merge. Karena itu, komentar manusia
dicatat sebagai masukan pasca-merge, bukan approval formal pada PR #2.

## Temuan dan keputusan

| # | Temuan | Keputusan dan bukti |
|---|---|---|
| 1 | Kegagalan add/edit/delete Notes membuat daftar sebelumnya hilang. | **Diperbaiki pada perubahan lokal tindak lanjut.** `NotesNotifier` mempertahankan data, mengatur state kembali ke `AsyncData`, lalu melempar ulang error. `NotesPage` menampilkan pesan `Failure` atau pesan cadangan melalui Snackbar. Test widget memverifikasi kegagalan ketiga operasi mempertahankan daftar dan menampilkan pesan. |
| 2 | Belum ada test untuk judul yang hanya berisi spasi. | **Ditutup.** Validator menggunakan `trim().isEmpty`; widget test baru mengisi spasi, memeriksa pesan validasi, dan memastikan repository tidak dipanggil. Test judul kosong tetap ada. |
| 3 | Pindahkan wiring repository karena provider mengimpor implementasi data. | **Tidak diubah.** Provider menjadi composition root; domain tetap tidak bergantung pada Flutter, Dio, atau SQLite. |
| 4 | Migrasikan Navigator ke GoRouter karena prompt menyebut GoRouter. | **Tidak diubah.** Tidak ada kebutuhan atau bug yang membenarkan migrasi. |
| 5 | Refresh Posts yang gagal menghilangkan cache. | **Tidak ada perubahan.** Test yang sudah ada membuktikan cache tetap tersedia dan failure diteruskan. `PostsNotifier.refresh` tidak diubah. |

## Ringkasan verifikasi

Pada workspace lokal, hasil pemeriksaan terbaru setelah perubahan Notes:

- `flutter analyze` — lulus, tidak ada masalah.
- `flutter test` — lulus, 27 test.

Empat file perbaikan Notes dan test masih merupakan perubahan lokal yang belum
dikomit atau dipush. Hasil lokal ini belum berarti perubahan tersebut telah
ditinjau atau di-approve di GitHub.
