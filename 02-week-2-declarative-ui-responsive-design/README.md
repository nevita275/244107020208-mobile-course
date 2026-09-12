## NAMA  : NEVITA TRIYA YULIANA <br>
## KELAS : TI-3F <br>
## ABSEN : 20 <br>


## Declarative UI & Responsive Design

<details>
<summary><h3>4. Praktikum: layout sederhana (warm-up)</h3></summary>
<br>
<blockquote>

## Ganti isi lib/main.dart
![](screenshots/code1.png)<br>
![](screenshots/code2.png)
## Output Awal
![](screenshots/output.png)
## Eksperimen warm-up
**1. Hapus Expanded pada baris nama, lalu amati peringatan overflow atau perilaku layout-nya; kembalikan setelah itu.** <br>
**Code**<br>
![](screenshots/codehapusexpandedpadabarisnama.png)<br>
**Output**<br>
Setelah Expanded dihapus, tampilan kartu profil tidak menunjukkan perubahan visual maupun error overflow. Layout tetap terlihat identik dengan versi sebelumnya.<br>
Tanpa Expanded, Row memberi Column di dalamnya ruang selebar-lebarnya, namun Column hanya akan mengambil lebar sesuai kontennya sendiri, bukan memaksa mengisi seluruh sisa ruang Row. Karena teks "Nevita Triya Yuliana" masih lebih pendek dari sisa ruang yang tersedia di dalam kartu (sekitar 236px dari total lebar kartu 320px), jadi tidak terjadi overflow. Expanded baru terlihat pengaruhnya secara visual ketika lebar konten melebihi ruang yang tersedia. Untuk membuktikan, teks nama diganti sementara menjadi lebih panjang:<br>
![](screenshots/codehapusexpandeddengannamapanjang.png)<br>
Output:<br>
![](screenshots/outputhapusexpandeddengannamapanjang.png)<br>
Dengan panjang nama tersebut, versi tanpa Expanded menghasilkan error RenderFlex overflowed, sedangkan versi dengan Expanded membuat teks otomatis membungkus ke baris berikutnya tanpa error, karena Column dipaksa membatasi lebarnya sesuai sisa ruang Row yang tersedia.<br><br>
**2. Ganti mainAxisSize: MainAxisSize.min menjadi nilai default dan amati perubahan tinggi kartu**<br>
**Code**<br>
![](screenshots/codedefaultminaxissize.png)<br>
**Output**<br>
![](screenshots/outputdefaultminaxissize.png)<br>
Default MainAxisSize untuk Column adalah max, artinya Column akan mencoba mengisi seluruh ruang vertikal yang tersedia dari parent-nya. Karena ProfileCard diletakkan di dalam Center, dan Center memberi loose constraints hingga sebesar layar, Column dengan mainAxisSize: max akan meregang memenuhi tinggi layar penuh sehingga kartu jadi terlihat sangat tinggi/panjang, bukan lagi membungkus kontennya. Dengan min, Column hanya setinggi jumlah tinggi childrennya saja, sehingga kartu tampak ringkas dan center secara vertikal.<br><br>
**3. Tambahkan satu baris data (misal Email) menggunakan pola Row + Expanded yang sama.**<br>
**Code**<br>
![](screenshots/codemenambahkanemail.png)<br>
**Output**<br>
![](screenshots/outputmenambahkanemail.png)<br>
Ditambahkan setelah baris Kelas, mengikuti pola Row + Expanded yang sama: label di kiri dibungkus Expanded agar mengambil sisa ruang dan mendorong nilai ke kanan, sedangkan nilai di kanan tidak dibungkus Expanded sehingga lebarnya mengikuti panjang teksnya sendiri.<br>
</blockquote>
</details>

<br>

<details>
<summary><h3>5. Praktikum: dashboard responsif</h3></summary>
<br>
<blockquote>

## Code Awal
![](screenshots/codepraktikum5.png)<br>
![](screenshots/codepraktikum5,.png)
## Output Awal
![](screenshots/outputprak5.png)
## Menambahkan interaksi: StatefulWidget dan Cupertino
![](screenshots/codemenambahstatefulWidgetdancupertino.png)
**Sesuaikan DashboardPage agar menerima state dan callback:**
**Code**
![](screenshots/dashboardpage1.png)<br>
![](screenshots/dashboardpage2.png)<br>
![](screenshots/dashboardpage3.png)<br>
**Output**<br>
![](screenshots/outputdashboardpage1.png)<br>
![](screenshots/outputdashboardpage2.png)
## Eksperimen layout
**1. Ubah breakpoint dari 700 menjadi nilai lain dan amati perubahan jumlah kolom.**<br>
**code**<br>
![](screenshots/codeubahnilai700menjadi500.png)<br>
**Output**<br>
![](screenshots/outputubahnilai700menjadi500.png)<br>
Dengan breakpoint 200, grid selalu menampilkan 2 kolom di hampir semua kondisi layar HP nyata, karena lebar layar portrait pada umumnya (≥360px) sudah jauh dari 200px. Perpindahan ke 1 kolom praktis tidak pernah teramati kecuali pada kondisi layar sangat sempit (mis.split-screen ekstrem). Efek sampingnya, kartu dashboard menjadi lebih sempit dari desain awal karena 2 kolom dipaksakan pada lebar layar HP yang jauh lebih kecil dari breakpoint asli (700px), berpotensi membuat konten teks di dalam DashboardCard (judul + nilai) menjadi lebih padat/berisiko overflow bila judul cukup panjang.<br><br>
**2. Ubah themeMode menjadi ThemeMode.dark, lalu kembalikan ke ThemeMode.system**<br>
**themeMode: ThemeMode.dark,**<br>
![](screenshots/themmodedark.png)<br>
![](screenshots/outputthemmodedark.png)<br>
**themeMode: ThemeMode.system,**
![](screenshots/themmodesystem.png)<br>
Karena mode Android fisik saya mode gelap jadi output dari ThemMode.system adalah tetap seperti ThemMode.dark<br><br>
**3. Uji aplikasi dengan ukuran layar emulator yang berbeda.**<br>
![](screenshots/ukuranlayarberbeda.png)<br>
**4. Tambahkan Semantics atau label yang bermakna pada elemen yang penting bagi screen reader.**<br>
Tanpa Semantics, screen reader tetap bisa membaca teks yang ada, namun teks-teks tersebut dibaca sebagai elemen terpisah, misalnya "Assignments" dan "8" dibaca dua kali berurutan tanpa konteks bahwa keduanya saling berkaitan. Dengan Semantics(label: ...), seluruh child di dalamnya digabung menjadi satu unit semantic dengan label yang sudah disusun secara bermakna, sehingga screen reader membacanya sebagai satu kalimat utuh ("Assignments: 8"), bukan potongan-potongan info yang terpisah.
</blockquote>
</details>

<br>

<details>
<summary><h3>6. Tugas dan AI design exploration</h3></summary>
<br>
<blockquote>

## Tugas utama
![](screenshots/tugasutamapotret.png)<br>
![](screenshots/tugasutamalanscape.png)

## AI Prompt Challenge
### 1. Perbandingan tata letak: GridView vs LayoutBuilder + Column<br>

**Prompt yang diajukan:** "Bandingkan dua tata letak dashboard akademik untuk
Flutter: versi GridView dan versi LayoutBuilder + Column. Jelaskan trade-off
responsif dan aksesibilitasnya."<br>

**Ringkasan jawaban AI:**<br>

GridView.count:<br>
- Ringkas (cukup ubah crossAxisCount untuk berubah jumlah kolom)<br>
- Spacing antar item tertangani otomatis lewat crossAxisSpacing/mainAxisSpacing<br>
- Trade-off responsif: childAspectRatio tetap membuat tinggi kartu seragam
  paksa, berisiko konten terpotong kalau teks jauh lebih panjang dari kartu lain<br>
- Trade-off aksesibilitas: urutan traversal screen reader mengikuti urutan children (row-major), umumnya intuitif, tapi perlu diverifikasi manual
  dengan TalkBack<br>

LayoutBuilder + Column (manual, tanpa GridView):<br>
- Tinggi tiap kartu tidak dipaksa seragam, kartu dengan konten lebih panjang bisa tumbuh natural tanpa overflow<br>
- Kode jauh lebih verbose — logika "kelompokkan 2 kartu per baris" harus ditulis manual dan rawan salah kalau jumlah kartu ganjil<br>
- Struktur widget linear (Column berisi Row) lebih mudah diprediksi urutan traversal-nya untuk aksesibilitas<br><br>

**Keputusan yang dipakai:** tetap GridView, karena kartu info pada dashboard ini berukuran seragam sehingga fleksibilitas tinggi dari pendekatan manual tidak diperlukan, dan kode tetap ringkas.<br><br>

### 2. Penguatan konsep: kapan Expanded menyebabkan overflow

**Prompt yang diajukan:** "Jelaskan kapan penggunaan Expanded justru
menyebabkan overflow di dalam Row, beri contoh kode yang gagal dan
perbaikannya."<br>

**Ringkasan jawaban AI:**<br>

Expanded justru mencegah overflow selama parent memberi batas lebar yang jelas (bounded). Masalah muncul ketika Row berada di dalam widget yang memberi lebar tak terbatas pada sumbu yang sama — contoh umum: Row di dalam SingleChildScrollView(scrollDirection: Axis.horizontal).<br>

Kode yang gagal:<br>
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Expanded(child: Container(color: Colors.red, height: 50)), // error
      Container(width: 100, color: Colors.blue, height: 50),
    ],
  ),
)
```
Error: "RenderFlex children have non-zero flex but incoming width constraints are unbounded" — karena scroll horizontal memberi lebar tak terbatas, sementara Expanded butuh sisa ruang yang jelas untuk menghitung porsinya.<br>

Perbaikan — ganti Expanded dengan lebar tetap:<br>
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Container(width: 200, color: Colors.red, height: 50),
      Container(width: 100, color: Colors.blue, height: 50),
    ],
  ),
)
```

### 3. Verification prompt

**Prompt yang diajukan:** "Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah 600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak tersedia di Flutter stabil saat ini?"<br>

**Ringkasan jawaban AI:**<br>

- Responsif di bawah 600px: ya, kWideBreakpoint memastikan crossAxisCount bernilai 1 pada lebar berapa pun di bawah nilai breakpoint<br>
- Mengurangi aksesibilitas: tidak, tapi ditemukan potensi redundansi, ikon dekoratif (dark_mode/light_mode) di sebelah switch berpotensi
  dibaca dua kali oleh screen reader bersama label Semantics switch. Diperbaiki dengan membungkus ikon tersebut dalam ExcludeSemantics<br>
- Widget tidak tersedia di Flutter stable: tidak ditemukan — CupertinoSwitch,
  GridView.count, LayoutBuilder, Semantics, dan ColorScheme (Material 3) semuanya API stabil<br>

**Perbaikan yang diterapkan dari audit ini:**<br>
```dart
ExcludeSemantics(
  child: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
),
``` 
**Hasil run versi dark**<br>
![](screenshots/tugasutamadark1.png)<br>
![](screenshots/tugasutamadark.png)

## Refactoring Challenge
## 1. Ekstrak kartu info jadi widget reusable
**1. InfoCard diekstrak menjadi widget reusable**<br>
  didefinisikan satu kali (`class InfoCard` di lib/main.dart) dan dipanggil 4x dengan parameter `title`/`value` berbeda, tanpa duplikasi struktur widget. Output visual tidak berubah dari sebelum diekstrak. Manfaatnya adalah kemudahan pemeliharaan, yaitu perubahan style kartu (padding, warna, dst) cukup dilakukan di satu tempat dan otomatis berlaku ke keempat kartu dibanding harus mengedit 4 blok kode terpisah yang rawan tidak
  konsisten.<br><br>
**2. Warna dan ukuran mengikuti Theme.of(context)**<br>
  seluruh warna di  InfoCard dan ProfileHeader diambil dari `theme.colorScheme` /`theme.textTheme`, bukan Colors.xxx hardcode. Diverifikasi dengan
  toggle tema: warna kartu dan header otomatis berubah mengikuti  light/dark tanpa perlu mengubah kode.<br><br>
**3. Breakpoint dipindahkan ke konstanta tunggal**<br>
  `kWideBreakpoint` di lib/constants.dart, dipakai satu tempat di LayoutBuilder, sehingga tidak ada angka breakpoint yang tersebar di banyak tempat.<br><br>
**4. Hasil flutter analyze:**<br>
![](screenshots/flutteranalyze.png)

## 4. Testing Dasar
**File test: `test/widget_test.dart`, berisi 2 widget test:**<br>
**1. Layar sempit (400x800)** — memverifikasi kartu ke-2 berada di bawah kartu ke-1 (perbedaan posisi Y > 30px), membuktikan layout 1 kolom.<br>
**2. Layar lebar (1200x800)** — memverifikasi kartu ke-1 dan ke-2 sejajar horizontal (perbedaan posisi Y < 5px), membuktikan layout 2 kolom.<br>
**Hasil flutter test:**<br>
![](screenshots/fluttertest.png)

</blockquote>
</details>

<br>

<details>
<summary><h3>7. Refleksi</h3></summary>
<br>
<blockquote>

**1. Apa perbedaan cara berpikir imperative dan declarative saat membangun UI?**<br>
Imperative menulis instruksi bagaimana mengubah UI langkah demi langkah. Sedangkan declarative cukup mendeskripsikan seperti apa UI untuk suatu state via `build()`, dan framework yang menentukan perubahannya. Terbukti saat `isDark` diubah yaitu cukup `setState()`, seluruh widget yang memakai `Theme.of(context)` otomatis menyesuaikan tanpa instruksi manual per elemen.<br><br>

**2. Kapan Expanded membantu dan kapan penggunaannya justru menghasilkan layout error?** <br>
Membantu ketika parent memberi batas ruang jelas, mencegah teks panjang di `ProfileHeader`/`InfoCard` overflow dan membuatnya wrap dengan benar. Menyebabkan error ketika Row/Column berada dalam widget berlebar tak terbatas, misalnya `Row` di dalam `SingleChildScrollView` horizontal (solusinya: lebar tetap, bukan Expanded). Terjadi saat menghapus Expanded pada baris nama (Praktikum 4) awalnya tidak menampakkan overflow karena teks masih muat, membuktikan efeknya baru terlihat saat konten melebihi ruang tersedia.<br><br>

**3. Bagaimana breakpoint dan theme memengaruhi pengalaman pengguna?** <br>
Breakpoint terlalu rendah (dicoba:200) membuat layout selalu 2 kolom bahkan di layar sempit, breakpoint 600 karena terbukti 1 kolom di portrait
dan 2 kolom di landscape pada device pengujian. Untuk theme, sempat ditemukan bug `themeMode` tertinggal di `ThemeMode.system` dari eksperimen sebelumnya sehingga switch terlihat tidak berfungsi menunjukkan `themeMode` harus benar-benar terikat ke state (`isDark ?... : ...`) agar kontrol manual pengguna efektif.<br><br>

**4. Apa yang Anda verifikasi dari rekomendasi AI setelah tugas inti selesai?**<br>
Tidak disalin mentah namun diverifikasi lewat `flutter analyze` (No issues found!), pengujian visual langsung di device fisik (portrait & landscape), `flutter test` (All testspassed!), dan TalkBack untuk memastikan label Semantics benar-benar terbaca. Temuan audit AI (Prompt 3) soal redundansi label pada ikon switch ditindaklanjuti nyata dengan `ExcludeSemantics`, bukan sekadar dicatat. Ini penting karena rekomendasi yang tampak benar secara teori (misal breakpoint 700) belum tentu cocok untuk device nyata yang dipakai, terbukti perlu disesuaikan jadi 600 setelah diuji langsung.

</blockquote>
</details>