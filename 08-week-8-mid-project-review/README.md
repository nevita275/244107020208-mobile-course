## NAMA  : NEVITA TRIYA YULIANA <br>
## KELAS : TI-3F <br>
## ABSEN : 20 <br>

# Mid Project Review & Code Review

Codelab Week 8 melanjutkan project portfolio dari Week 5–7, bukan membuat
aplikasi baru. Project ini memakai aplikasi Week 7: Notes offline-first dan
Posts cache-first dengan feature-first Clean Architecture. Tujuan review
tengah semester adalah membuktikan bahwa perubahan dapat dipahami, diuji, dan
direview bersama sebelum fitur semester berikutnya ditambahkan.

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
1–7. Branch fitur Week 8 dibuat dari `develop`; setelah perubahan Week 8
di-commit dan dipush, branch itu memuat seluruh folder Week 1–8.

Saat ini perubahan Week 8 sudah di-stage secara lokal, tetapi belum menjadi
commit atau tersedia di GitHub. Jangan menganggap branch fitur remote atau PR
sudah dibuat.

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

### Membuat issue dan branch kerja

Sebelum membuka PR, buat issue yang menjelaskan masalah. Branch remote
`develop` sudah tersedia dan berisi Week 1–7. Perubahan Week 8 sudah di-stage
pada branch fitur lokal yang sedang digunakan. Setelah Anda meninjau daftar
staged files, buat commit dan push branch fitur:

```powershell
git status
git diff --cached --check
git commit -m "feat(week8): add mid-project review project"
git push -u origin feature/08-week-8-mid-project-review
```

Perintah `commit` dan `push` di atas dijalankan oleh Anda. Setelah branch fitur
berisi Week 1–8 tersedia di GitHub, buat PR dari branch fitur ke `develop`.
Jangan commit Week 8 langsung ke `develop`; merge melalui PR setelah review.
Untuk Week 9 dan seterusnya, setelah PR minggu sebelumnya di-merge, buat
branch fitur baru dari `develop` terbaru.

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

Belum ada review teman pada project ini. Isi temuan dan status review di
[`docs/review-checklist.md`](docs/review-checklist.md) setelah review benar-
benar dilakukan.

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

Runner platform seperti `android/`, `ios/`, dan desktop sengaja tidak disertakan
dalam push portfolio ini. Setelah clone, buat ulang runner Android sebelum
menjalankan aplikasi:

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
CI belum berjalan karena branch belum dipublikasikan dan PR belum dibuat.

### CI untuk Pull Request

Workflow GitHub Actions tidak disertakan dalam cakupan push yang dipilih.
Jalankan `flutter analyze`, `dart format --set-exit-if-changed .`, dan
`flutter test` secara lokal sebelum mengirim PR. Workflow dapat ditambahkan
kemudian jika diperlukan tim.

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

Belum ada PR Week 8, jadi catatan AI merupakan review awal terhadap kode
salinan Week 7, bukan review PR sejawat. Tindak lanjut yang sudah dilakukan:

1. **Diterima:** usulan widget test untuk judul kosong. Test baru membuktikan
   validasi menolak input dan tidak menyimpan catatan.
2. **Perlu dibahas:** pertahankan daftar Notes dan beri umpan balik saat operasi
   gagal; perubahan perilaku belum diterapkan.
3. **Ditolak:** memindahkan wiring repository hanya untuk menghilangkan import
   implementasi dari provider. Provider menjadi composition root; domain tetap
   tidak mengimpor Flutter, Dio, atau SQLite.

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

Selesaikan langkah berikut bersama pasangan:

1. Buat issue dan satu PR kecil dari branch `feature/*` menuju `develop`.
2. Isi PR dengan masalah, solusi, cara uji, dan screenshot aplikasi.
3. Lampirkan hasil `flutter analyze` dan `flutter test` yang aktual.
4. Dokumentasikan prompt AI, usulan, keputusan, dan bukti di folder `docs/`.
5. Setelah review sejawat, perbarui tabel temuan dan tindak lanjut.
6. Merge hanya setelah approve; pastikan issue tertutup dan catat tautannya.

Peta status tersedia di
[`docs/review-checklist.md`](docs/review-checklist.md).

### Pertanyaan refleksi

Jawab setelah peer review selesai:

- Apa beda LGTM buta dengan approve yang bertanggung jawab? Apa risikonya?
- Kapan komentar harus berstatus **Request changes**, dan kapan cukup saran?
- Saran AI mana yang ditolak atau disederhanakan, dan apa alasan teknisnya?
- Apa satu hal yang diperbaiki setelah review sejawat dan apa dampaknya?

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
