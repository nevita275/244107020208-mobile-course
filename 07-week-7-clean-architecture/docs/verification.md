# Hasil verifikasi Week 7

Perintah berikut dijalankan dari folder project
`07-week-7-clean-architecture`.

## 1. Presentation bebas akses data mentah

```powershell
rg "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/notes/presentation lib/features/posts/presentation lib/pages
```

Output: `No matches found.` (exit code 1 berarti tidak ada pola yang ditemukan).

## 2. Domain/core bebas import framework dan driver

```powershell
rg "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase" lib/features/notes/domain lib/features/posts/domain lib/core
```

Output: `No matches found.` (exit code 1 berarti tidak ada pola yang ditemukan).

## 3. Domain bebas mapping data mentah

```powershell
rg "toMap|fromMap|toJson|fromJson|jsonEncode|jsonDecode" lib/features/notes/domain lib/features/posts/domain
```

Output: `No matches found.` (exit code 1 berarti tidak ada pola yang ditemukan).

## Static analysis dan test

```text
flutter analyze
No issues found!

flutter test
22 tests passed.
```

Test meliputi fake repository Notes/Posts, hasil use case sukses dan failure,
cache-first/offline, sinkronisasi, preferensi, serta formatting tanggal dan
parsing route. Test tidak membutuhkan database atau request HTTP sungguhan.

## Verifikasi visual

`flutter build apk` berhasil menghasilkan Android release APK sebesar 55.8 MB.

Folder `screenshots/` menyimpan screenshot baseline Week 5 (`run1.png`–`run9.png`)
dan hasil aplikasi Week 7 yang di-capture langsung dari HP Android fisik
(Android 16, resolusi 1080 × 2400):

- `week7-notes.png`: halaman Notes dengan dua catatan contoh lokal berstatus
  belum sinkron.
- `week7-posts.png`: halaman Posts dengan data terbaru dari jaringan.

Keduanya merupakan screenshot perangkat fisik, bukan Chrome. Banner DEBUG
tampil karena aplikasi yang berjalan di HP adalah build debug dari `flutter run`.
