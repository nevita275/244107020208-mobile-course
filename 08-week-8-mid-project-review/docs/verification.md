# Verifikasi Week 8

Jalankan dari folder `08-week-8-mid-project-review`.

## Pemeriksaan lokal

| Perintah | Hasil |
|---|---|
| `flutter analyze` | Lulus — `No issues found!` |
| `dart format --set-exit-if-changed .` | Lulus — 30 file, 0 berubah. |
| `flutter test` | Lulus — 23 test. |

Pemeriksaan dijalankan pada project Week 8 setelah seluruh source dan test
Week 7 disalin. Widget test baru memverifikasi bahwa judul kosong ditolak.
Workflow CI GitHub tidak disertakan dalam cakupan file yang akan dipush.

`flutter run -d 24117RN76O --no-resident` berhasil membangun, memasang, dan
meluncurkan aplikasi pada perangkat Android 16. Interaksi CRUD/offline dan
screenshot baru untuk PR masih perlu dilakukan.

## Pemeriksaan dependency rule

Tiga pencarian sterilitas menghasilkan `No matches found`:

1. Akses Dio/SQLite/secure storage/JSON mentah di presentation.
2. Import Flutter/driver di domain dan core.
3. Mapping `Map`/JSON di entity dan kontrak repository domain.

## Uji manual dan screenshot

- [x] Build/install/launch berhasil di Android 16.
- [x] Widget test memastikan form menolak judul kosong; uji manual judul spasi
  masih menunggu device.
- [ ] Tambah, edit, hapus catatan dan periksa status sinkronisasi.
- [ ] Buka Posts saat online dan saat offline/cache tersedia.
- [ ] Simpan screenshot baru pada `screenshots/` dan lampirkan pada PR.

Screenshot yang saat ini tersedia (`week7-notes.png` dan `week7-posts.png`)
adalah baseline tampilan Week 7 untuk perbandingan, bukan hasil uji Week 8.
