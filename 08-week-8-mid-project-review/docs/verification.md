# Verifikasi Week 8

Jalankan perintah dari root repository pada PowerShell:

```powershell
Set-Location .\08-week-8-mid-project-review
flutter pub get
flutter analyze
dart format --set-exit-if-changed .
flutter test
```

## Hasil terbaru yang dijalankan secara lokal

| Perintah | Hasil |
|---|---|
| `flutter pub get` | Berhasil pada workspace lokal. |
| `flutter analyze` | Lulus — `No issues found!`. |
| `dart format --set-exit-if-changed .` | Lulus pada pemeriksaan sebelumnya: 30 file, 0 berubah. |
| `flutter test` | Lulus — 27 test. |
| `flutter build apk --debug` | Lulus pada workspace lokal; belum merupakan build dari clone bersih. |

Test baru meliputi penolakan judul yang hanya berisi spasi dan kegagalan add,
update, serta delete Notes. Pada tiap kegagalan CRUD, test memeriksa bahwa daftar
sebelumnya tetap tampil dan pesan kegagalan muncul. Test judul kosong tetap
dipertahankan.

Hasil ini berasal dari workspace lokal. PR #2 yang sudah merged tidak
menyertakan manifest Week 8; konfigurasi pada perubahan tindak lanjut perlu
di-commit dan dipush sebelum reviewer dapat mengulang pemeriksaan dari clone
GitHub yang bersih. Tidak ada workflow CI dalam project.

## Pemeriksaan arsitektur dan manual

Pencarian dependency rule dijalankan terhadap source Week 8; hasil yang
dilaporkan sebelumnya tidak menemukan akses driver dari presentation/domain
yang melanggar aturan. Posts dan perilaku cache tidak diubah dalam tindak lanjut
ini.

- [x] Flutter analyze dan seluruh 27 test lulus secara lokal.
- [x] APK debug berhasil di-build pada workspace lokal.
- [ ] Build dan launch ulang dari clone bersih setelah perubahan runner dan
  konfigurasi tersedia di GitHub.
- [ ] Uji manual CRUD Notes, Posts online, cache, dan offline.

## Screenshot

File yang benar-benar tersedia sebagai screenshot Week 8 adalah
[`notes.png`](../screenshots/notes.png) dan
[`posts.png`](../screenshots/posts.png). Keduanya berasal dari baseline
aplikasi Week 7; jangan menyebutnya bukti interaksi CRUD baru atau kondisi
offline kecuali kondisi tersebut memang terlihat dan diverifikasi.
