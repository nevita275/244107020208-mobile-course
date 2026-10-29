## NAMA  : NEVITA TRIYA YULIANA <br>
## KELAS : TI-3F <br>
## ABSEN : 20 <br>

# Mid Project Review & Code Review

<details>
<summary><h2>Praktikum 1: Hygiene branch dan commit</h2></summary>
<br>
<blockquote>

### Branching model

Setiap branch memiliki satu tujuan:

| Branch | Peran | Aturan |
|---|---|---|
| `main` | Rilis yang stabil | Tidak mengerjakan fitur langsung di branch ini. |
| `develop` | Integrasi pekerjaan mingguan | Menjadi target Pull Request fitur. |
| `feature/*` | Pengembangan satu fitur | Dibuat dari `develop`; usahakan kecil dan selesai kurang dari 3 hari. |
| `fix/*` | Perbaikan bug | Sertakan langkah reproduksi dan test. |

Susunan branch yang dituju:

```text
main      -> rilis stabil
develop   -> integrasi fitur
feature/* -> satu fitur untuk direview
fix/*     -> satu perbaikan beserta test
```

### Audit repository dan riwayat

Perintah audit:

```powershell
git log --oneline -15
git branch -a
git status
```

Saat menyiapkan project ini, `origin/main` berisi folder Week 1–7 dan belum
memiliki branch remote `develop`. Branch `develop` kemudian dibuat dari
`origin/main` dan sudah dipush ke remote, sehingga sekarang memuat folder Week
1–7. Branch fitur Week 8 dibuat dari `develop`; commit `dc39f06` sudah
dipush, sehingga branch fitur memuat folder Week 1–8.

Branch `main` dan `develop` saat ini berada pada commit yang sama; keduanya
belum berisi Week 8. Branch fitur Week 8 sudah ada di GitHub, tetapi Pull
Request belum dibuat. Perbandingan GitHub pada screenshot memilih `main` sebagai
base; sebelum membuat PR, ubah base menjadi `develop` dan biarkan compare tetap
`feature/08-week-8-mid-project-review`.

### Isi branch sekarang dan untuk Week 9–16

Branch fitur bukan branch terpisah yang hanya berisi satu folder tugas.
Branch `feature/08-week-8-mid-project-review` membawa riwayat dan folder Week
1–7 dari `develop`, lalu menambahkan pekerjaan Week 8. Setelah commit Week 8
di-push, isi branch fitur tersebut akan mencakup Week 1–8.

Alur kumulatif selanjutnya:

```text
develop (Week 1–7)
  └── feature/08... (Week 1–7 + perubahan Week 8)
        └── PR dan review -> merge ke develop (Week 1–8)
              └── feature/09... (Week 1–8 + perubahan Week 9)
                    └── PR dan review -> merge ke develop (Week 1–9)
```

Setelah setiap PR disetujui dan di-merge, `develop` berisi semua minggu yang
sudah selesai. Branch fitur minggu berikutnya dibuat dari `develop` terbaru,
sehingga membawa folder minggu sebelumnya dan menambahkan pekerjaan minggu
baru. Jangan merge Week 8 ke `develop` sebelum PR-nya direview dan disetujui.
`main` adalah branch rilis; jangan masukkan Week 8 langsung ke `main`. Integrasi
dari `develop` ke `main` dilakukan melalui PR rilis ketika kumpulan pekerjaan
memang siap dirilis.

Contoh audit tiga pesan commit sebelumnya dan perbaikannya:

| Pesan lama | Usulan pesan yang lebih jelas | Alasan |
|---|---|---|
| `menambahkan di readme` | `docs(readme): tambahkan navigasi tugas mingguan` | Menjelaskan tipe perubahan dan lokasi dokumentasi. |
| `menambahkan di readme` | `docs(readme): perbarui navigasi tugas mingguan` | Membedakan perubahan dokumentasi dari commit sebelumnya. |
| `praktikum week 7` | `docs(week7): dokumentasikan hasil praktikum clean architecture` | Menjelaskan cakupan dan isi perubahan. |

Tabel tersebut adalah latihan penulisan pesan, bukan perubahan riwayat. Jangan
amend atau rewrite commit lama untuk latihan ini.

### Format commit

Gunakan `tipe(scope): deskripsi singkat`, misalnya:

```text
feat(notes): validasi judul kosong + test
fix(auth): refresh token sebelum retry satu kali
docs(week8): dokumentasikan hasil code review
```

Tipe yang disarankan: `feat`, `fix`, `refactor`, `test`, `docs`, dan `chore`.
Satu commit sebaiknya mewakili satu perubahan logis yang dapat direview dan
di-revert.

</blockquote>
</details>

<br>

<details>
<summary><h2>Praktikum 2: Pull Request dan peer review</h2></summary>
<br>
<blockquote>

### Membuat issue

Branch remote `develop` berisi Week 1–7, sedangkan
`feature/08-week-8-mid-project-review` sudah berisi perubahan Week 8. Buat
issue dulu agar tujuan PR dan kriteria selesai jelas:

1. Buka repository GitHub, pilih tab **Issues**, lalu **New issue**.
2. Isi judul, misalnya `Week 8: mid-project review aplikasi portfolio`.
3. Isi deskripsi dengan masalah, ruang lingkup review, dan kriteria selesai.
   Contoh:

   ```text
   Masalah: project portfolio perlu diverifikasi sebelum pekerjaan Week 9.
   Cakupan: review state/error Notes, validasi input, cache Posts,
   dependency rule, test, dan dokumentasi.
   Kriteria selesai: hasil analyze/test dicatat, temuan ditindaklanjuti,
   serta PR ke develop direview sebelum merge.
   ```

4. Pilih **Submit new issue** dan catat nomor issue yang dibuat.

### Membuat Pull Request

Setelah issue dibuat, buka tab **Pull requests** → **New pull request**.
Pada halaman perbandingan, atur:

```text
base:    develop
compare: feature/08-week-8-mid-project-review
```

Screenshot perbandingan sebelumnya memilih `main` sebagai base. Buka dropdown
base dan ganti ke `develop`; jangan lanjutkan jika base masih `main`. Pastikan
GitHub menampilkan perubahan Week 8 yang diharapkan, lalu pilih **Create pull
request**.

Isi judul, misalnya:

```text
feat(week8): mid-project review aplikasi portfolio
```

Di deskripsi PR, jelaskan masalah, solusi, cara uji, dan screenshot. Tambahkan
`Closes #<nomor-issue>` menggunakan nomor issue yang baru dibuat. Jangan
menggabungkan PR langsung ke `main`; target integrasi mingguan adalah
`develop`. `main` tetap untuk rilis setelah pekerjaan di `develop` siap.

**Catatan reproduksibilitas:** atas keputusan scope repository, manifest
Flutter tidak ada dalam branch. Reviewer yang melakukan clone tidak dapat
langsung menjalankan `flutter pub get`, `flutter analyze`, atau `flutter test`.
Jelaskan keterbatasan ini pada PR atau sertakan file manifest yang dibutuhkan
jika reviewer harus menjalankan ulang test dari clone.

### Isi PR

PR harus menjelaskan masalah, solusi, cara uji, dan screenshot. Template yang
siap disalin ada di [`docs/pr-template.md`](docs/pr-template.md). Contoh:

```text
Judul: test(notes): verifikasi validasi judul kosong
Masalah: form catatan harus mencegah judul kosong disimpan.
Solusi: tambahkan widget test untuk form tambah catatan.
Cara uji: flutter test test/notes_page_test.dart
Screenshot: lampirkan screenshot aplikasi. Screenshot Notes/Posts yang ada di
folder `screenshots/` dapat digunakan kembali untuk menunjukkan tampilan
aplikasi yang dilanjutkan dari Week 7. Untuk PR tentang perilaku offline,
sertakan screenshot tambahan yang menunjukkan status cache/offline secara
aktual.
Closes #<nomor-issue>
```

PR sebaiknya satu fitur, kurang dari 300 baris perubahan, dan dapat direview
dalam waktu singkat. Jangan menulis `Closes #...` sebelum nomor issue nyata
tersedia.

### Review sejawat

Reviewer diminta checkout branch, menjalankan aplikasi dan test, lalu menulis
komentar yang bisa ditindaklanjuti. Cakupan minimum codelab:

- 2 temuan kebenaran: null, state, alur error, atau edge case.
- 1 temuan arsitektur: arah import, DI, atau model yang bocor ke UI.
- 1 temuan test dan 1 saran keterbacaan.
- Keputusan akhir: **Approve** atau **Request changes**.

Pola komentar yang digunakan:

```text
Observasi: fungsi ini mengerjakan validasi dan penyimpanan sekaligus.
Dampak: aturan validasi sulit diuji terpisah.
Usulan: tambahkan test untuk judul kosong dan spasi sebelum menyimpan.
```

#### Catatan review teknis untuk perubahan ini

Berikut komentar konstruktif yang dapat dipakai untuk membahas PR. Temuan
pertama perlu dipertimbangkan sebelum merge:

1. **Kebenaran/state — perlu perubahan atau keputusan eksplisit.** Jika
   repository gagal saat tambah, edit, atau hapus catatan, `AsyncValue.guard`
   mengubah `notesProvider` menjadi error. Akibatnya daftar yang sebelumnya
   tampil digantikan error umum. Pertahankan data terakhir dan tampilkan pesan
   kegagalan yang sesuai aksi; tambahkan test untuk jalur gagal.
2. **Test — saran.** Validator sudah menolak judul kosong dan memangkas spasi,
   tetapi widget test baru mencakup nilai kosong. Tambahkan kasus judul yang
   hanya berisi spasi agar aturan yang sama terlindungi.
3. **Arsitektur — tidak perlu perubahan.** Provider yang merakit repository
   dapat berperan sebagai composition root. Pemeriksaan menunjukkan domain
   tidak mengimpor Flutter, Dio, atau SQLite; tidak perlu memindahkan wiring
   hanya demi menghilangkan import tersebut.
4. **Cache Posts — sudah tercakup.** Test refresh gagal memastikan data cache
   tetap tersedia dan failure diteruskan ke state.
5. **Keterbacaan — saran.** Pada perubahan berikutnya, pisahkan operasi
   mutation Notes dari pemetaan tampilan error agar alur sukses/gagal lebih
   mudah diikuti dan diuji.

Catat keputusan atas setiap temuan dan tindak lanjut di
[`docs/review-checklist.md`](docs/review-checklist.md). Komentar ini merupakan
masukan teknis untuk dibahas; status PR tetap **belum di-approve** sampai
review dan keputusan dicatat pada GitHub.

### Tindak lanjut dan merge

Author menanggapi komentar, memperbaiki yang disepakati, lalu meminta
re-review. Jangan merge saat status masih **Request changes**. Setelah
**Approve**, merge melalui GitHub, pastikan issue tertutup, dan hapus branch
fitur remote bila sudah tidak diperlukan.

</blockquote>
</details>

<br>

<details>
<summary><h2>Praktikum 3: Static analysis dan mid review</h2></summary>
<br>
<blockquote>

### Menjalankan aplikasi

Jalankan perintah dari folder `08-week-8-mid-project-review`:

```powershell
flutter pub get
flutter devices
flutter run -d <device-id>
```

Atas keputusan author, `pubspec.yaml`, `pubspec.lock`, dan
`analysis_options.yaml` tidak ikut dipush. Karena itu folder Week 8 pada branch
remote belum dapat berdiri sendiri sebagai package Flutter: reviewer tidak
bisa menjalankan `flutter pub get`, `flutter analyze`, atau `flutter test` dari
hasil clone sampai file konfigurasi itu disediakan. Pemeriksaan yang tercatat
di bawah dilakukan pada workspace lokal yang masih memiliki file tersebut.
Ini perlu dipertimbangkan sebelum meminta review yang harus dapat direproduksi.

Runner platform seperti `android/`, `ios/`, dan desktop juga tidak disertakan
dalam push portfolio ini. Setelah konfigurasi package tersedia, buat ulang
runner Android sebelum menjalankan aplikasi:

```powershell
flutter create --platforms android .
flutter pub get
flutter run -d <device-id>
```

Project mewarisi aplikasi Week 7: Notes menggunakan SQLite lokal, sedangkan
Posts mengambil data melalui Dio dan memakai cache lokal. Web tersedia sebagai
scaffold, tetapi fitur penyimpanan SQLite aplikasi tidak didukung pada web.

### Pemeriksaan mesin

Jalankan tiga pemeriksaan sebelum meminta review:

```powershell
flutter analyze
dart format --set-exit-if-changed .
flutter test
```

Hasil yang sudah dijalankan pada salinan Week 8:

| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze` | Lulus — tidak ada masalah. |
| `dart format --set-exit-if-changed .` | Lulus — 30 file, tidak ada yang berubah. |
| `flutter test` | Lulus — 23 test, termasuk widget test validasi judul kosong. |
| Build dan peluncuran Android | Berhasil pada Android 16. |

Rincian dan batas uji manual ada di [`docs/verification.md`](docs/verification.md).
CI belum berjalan karena workflow tidak disertakan dan PR belum dibuat.

### CI untuk Pull Request

Workflow GitHub Actions tidak disertakan dalam cakupan push yang dipilih.
Jalankan `flutter analyze`, `dart format --set-exit-if-changed .`, dan
`flutter test` secara lokal sebelum mengirim PR. Karena file konfigurasi
package juga tidak ikut dipush, reviewer perlu mendapatkan file tersebut
terlebih dahulu untuk mengulang pemeriksaan dari clone.

### Checklist kesiapan tengah semester

- [x] Project lanjutan Week 7 dengan struktur feature-first.
- [x] Tiga pemeriksaan dependency rule menghasilkan nol temuan.
- [x] Analyze, formatter, dan test lulus secara lokal.
- [ ] Jalankan uji manual Notes, Posts online, dan Posts dalam kondisi offline.
- [x] Screenshot Notes dan Posts tersedia di folder `screenshots/` dan dapat
  digunakan kembali karena aplikasi Week 8 melanjutkan aplikasi Week 7 tanpa
  perubahan tampilan pada kedua halaman tersebut.
- [ ] Jika PR membahas perilaku offline secara khusus, lampirkan juga bukti
  Posts yang benar-benar diambil saat cache/offline aktif.
- [ ] Buat issue dan PR kecil, lalu dapatkan review dan approve teman.
- [ ] Tindak lanjuti komentar dan merge PR melalui review.
- [ ] Perbarui README dengan tautan issue/PR serta bukti hasil aktual.

Mid review **belum dinyatakan lolos** sampai langkah kolaborasi dan uji manual
yang tersisa selesai.

</blockquote>
</details>

<br>

<details>
<summary><h2>AI Challenge: verifikasi saran review</h2></summary>
<br>
<blockquote>

### Prompt review

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

Prompt ini disimpan di [`docs/ai-review-vs-keputusan.md`](docs/ai-review-vs-keputusan.md).
Prompt menyebut GoRouter, tetapi aplikasi Week 7 ini memakai Navigator; jangan
menganggap perbedaan tersebut sebagai bug tanpa kebutuhan migrasi.

### Hasil verifikasi awal

Belum ada PR Week 8, jadi catatan berikut merupakan pemeriksaan awal terhadap
kode branch fitur, bukan temuan dari PR tertentu. Lima poin dirangkum sebagai
berikut:

1. **Perlu diperbaiki:** kegagalan operasi Notes membuat daftar diganti layar
   error umum; pertahankan data dan tampilkan umpan balik aksi.
2. **Diterima dan diterapkan:** tambah widget test untuk judul kosong.
3. **Saran test:** tambahkan kasus judul yang hanya berisi spasi.
4. **Ditolak:** memindahkan wiring provider yang berfungsi sebagai composition
   root; domain tetap tidak mengimpor Flutter, Dio, atau SQLite.
5. **Tidak ditemukan cacat:** test membuktikan kegagalan refresh Posts tetap
   mempertahankan cache; migrasi Navigator ke GoRouter juga tidak diperlukan.

Alasan dan bukti rinci ada di [`docs/ai-review-vs-keputusan.md`](docs/ai-review-vs-keputusan.md).
Saran AI harus diverifikasi dengan kode, test, dan aturan dependency sebelum
diterapkan. Keputusan final tetap milik author.

</blockquote>
</details>

<br>

<details>
<summary><h2>Refactoring, pengujian, dan screenshot offline</h2></summary>
<br>
<blockquote>

### Perubahan yang disiapkan

- Mempertahankan aplikasi Week 7 Notes dan Posts sebagai project yang direview.
- Memperbarui nama package menjadi `week8_mid_project_review`.
- Menambahkan widget test untuk memastikan judul kosong tidak dapat disimpan.
- Menambahkan dokumentasi checklist review, template PR, dan keputusan AI.
- Menambahkan `.gitignore` agar file generated dan runner platform tidak ikut
  dalam push portfolio.

### Mengambil screenshot Posts dengan cache

Folder `screenshots/` berisi `notes.png` dan `posts.png`, yaitu screenshot
aplikasi Week 7 yang nama filenya telah disesuaikan untuk portfolio Week 8.
Screenshot tersebut boleh dipakai kembali karena Week 8 melanjutkan aplikasi
yang sama dan halaman Notes/Posts tidak diubah. `posts.png` menunjukkan halaman
Posts, tetapi hanya membuktikan kondisi offline jika screenshot itu memang
diambil ketika cache/offline aktif. Untuk membuat bukti Posts offline:

1. Sambungkan HP ke internet dan jalankan aplikasi.
2. Buka **Posts** dan tunggu data tampil. Provider memuat cache terlebih dahulu
   dan memperbarui cache dari jaringan saat tersedia.
3. Kembali ke Catatan, buka **Pengaturan**, lalu aktifkan **Simulasi offline**.
4. Buka Posts lagi. Data tersimpan semestinya tetap terlihat; banner
   menunjukkan data dari cache.
5. Jika `posts.png` yang sudah ada tidak memperlihatkan kondisi cache/offline,
   ambil screenshot tambahan yang menampilkan daftar dan status cache. Simpan
   di folder `screenshots/`, kemudian lampirkan pada PR yang membahas perilaku
   offline.

Untuk menguji **mode pesawat sebenarnya**, isi cache dahulu seperti langkah di
atas, aktifkan mode pesawat Android dan pastikan Wi-Fi juga mati. Buka atau
muat ulang Posts, lalu screenshot tampilan dan catat bahwa jaringan perangkat
benar-benar dimatikan. Simulasi offline di aplikasi adalah alternatif uji yang
lebih mudah diulang, tetapi bukan bukti bahwa radio jaringan perangkat mati.

### Uji manual yang masih perlu dilakukan

- [x] Aplikasi berhasil di-build, dipasang, dan diluncurkan pada Android 16.
- [x] Widget test judul kosong lulus.
- [ ] Uji tambah, edit, dan hapus Notes di perangkat.
- [ ] Uji Posts online, cache, dan mode pesawat/offline di perangkat.
- [x] Gunakan screenshot Notes dan Posts yang tersedia untuk dokumentasi
  tampilan aplikasi.
- [ ] Untuk bukti perilaku offline/mode pesawat, pastikan screenshot
  memperlihatkan kondisi tersebut atau ambil screenshot tambahan saat
  offline aktif.

</blockquote>
</details>

<br>

<details>
<summary><h2>Tugas, refleksi, dan status kolaborasi</h2></summary>
<br>
<blockquote>

### Tugas portfolio Week 8

Alur tugas yang disarankan codelab adalah:

1. Buat issue dan satu PR kecil dari branch `feature/*` menuju `develop`.
2. Isi PR dengan masalah, solusi, cara uji, dan screenshot aplikasi.
3. Lampirkan hasil `flutter analyze` dan `flutter test` yang aktual.
4. Dokumentasikan prompt AI, usulan, keputusan, dan bukti di folder `docs/`.
5. Setelah review sejawat, perbarui tabel temuan dan tindak lanjut.
6. Merge hanya setelah approve; pastikan issue tertutup dan catat tautannya.

Peta status tersedia di
[`docs/review-checklist.md`](docs/review-checklist.md).

### Refleksi

1. **LGTM buta vs approve bertanggung jawab.** LGTM buta menyatakan setuju
   tanpa memeriksa bukti. Approve bertanggung jawab berarti memahami konteks,
   menelusuri jalur sukses dan gagal, memeriksa test, dan menilai dampak
   perubahan. LGTM buta bisa meloloskan state yang salah, kegagalan yang tidak
   ditangani, atau regresi yang baru diketahui pengguna.
2. **Request changes vs saran.** Gunakan **Request changes** bila temuan dapat
   menyebabkan perilaku salah, crash, data tidak tersedia/hilang, pelanggaran
   aturan arsitektur yang disepakati, atau kriteria tugas tidak terpenuhi.
   Komentar saran cukup untuk peningkatan keterbacaan/opsional yang tidak
   menghalangi perilaku maupun pemeliharaan.
3. **Saran yang ditolak.** Pemindahan wiring repository hanya karena provider
   mengimpor implementasi data tidak diperlukan. Provider berfungsi sebagai
   composition root; pemeriksaan menunjukkan domain tidak mengimpor Flutter,
   Dio, atau SQLite. Migrasi Navigator ke GoRouter juga tidak diperlukan:
   tidak ada kebutuhan perubahan atau cacat yang terbukti.
4. **Perbaikan yang dilakukan.** Widget test ditambahkan untuk memastikan
   judul catatan kosong ditolak dan tidak disimpan. Dampaknya, validasi yang
   sebelumnya tampak pada implementasi UI kini memiliki pemeriksaan regresi
   otomatis.

Temuan perilaku yang masih perlu ditindaklanjuti adalah kegagalan add/edit/
delete Notes mengubah seluruh provider menjadi `AsyncError`, sehingga daftar
yang sebelumnya tampil digantikan layar error umum. Kode belum diubah; rincian
dan usulan perbaikannya tercatat di [`docs/ai-review-vs-keputusan.md`](docs/ai-review-vs-keputusan.md).

### Referensi

- [Codelab Week 8: Mid Project Review & Code Review](https://jti-polinema.github.io/flutter-codelab/08-minggu-8-mid-project-review-code-review/)
- [Slide Week 8](https://jti-polinema.github.io/flutter-codelab/00-slides/Week_08_Mid_Project_Review_Code_Review.html)
- [Atlassian: GitFlow workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [GitHub: Pull request reviews](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews)
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Flutter: Static analysis](https://docs.flutter.dev/tools/using-ide)
- [Dart: Linter rules](https://dart.dev/tools/linter-rules)
- [GitHub Actions](https://docs.github.com/en/actions)

</blockquote>
</details>
