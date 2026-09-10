## NAMA  : NEVITA TRIYA YULIANA <br>
## KELAS : TI-3F <br>
## ABSEN : 20 <br>


## Declarative UI & Responsive Design

<details>
<summary><h3>4. Praktikum: layout sederhana (warm-up)</h3></summary>
<br>
<blockquote>

## Ganti isi lib/main.dart
![](screenshots/code1.png)
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
![](screenshots/codepraktikum5.png)
![](screenshots/codepraktikum5,.png)
## Output Awal
![](screenshots/outputprak5.png)
## Menambahkan interaksi: StatefulWidget dan Cupertino
![](screenshots/codemenambahstatefulWidgetdancupertino.png)
**Sesuaikan DashboardPage agar menerima state dan callback:**
**Code**
![](screenshots/dashboardpage1.png)
![](screenshots/dashboardpage2.png)
![](screenshots/dashboardpage3.png)
**Output**
![](screenshots/outputdashboardpage1.png)
![](screenshots/outputdashboardpage2.png)
## Eksperimen layout
**1. Ubah breakpoint dari 700 menjadi nilai lain dan amati perubahan jumlah kolom.**<br>
**code**<br>
![](screenshots/codeubahnilai700menjadi500.png)<br>
**Output**<br>
![](screenshots/outputubahnilai700menjadi500.png)<br>
Dengan breakpoint 200, grid selalu menampilkan 2 kolom di hampir semua kondisi layar HP nyata, karena lebar layar portrait pada umumnya (≥360px) sudah jauh dari 200px. Perpindahan ke 1 kolom praktis tidak pernah teramati kecuali pada kondisi layar sangat sempit (mis.split-screen ekstrem). Efek sampingnya, kartu dashboard menjadi lebih sempit dari desain awal karena 2 kolom dipaksakan pada lebar layar HP yang jauh lebih kecil dari breakpoint asli (700px), berpotensi membuat konten teks di dalam DashboardCard (judul + nilai) menjadi lebih padat/berisiko overflow bila judul cukup panjang.<br>
**2. Ubah themeMode menjadi ThemeMode.dark, lalu kembalikan ke ThemeMode.system**<br>
**themeMode: ThemeMode.dark,**
![](screenshots/themmodedark.png)<br>
![](screenshots/outputthemmodedark.png)
**themeMode: ThemeMode.system,**
![](screenshots/themmodesystem.png)<br>
Karena mode Android fisik saya mode gelap jadi output dari ThemMode.system adalah tetap seperti ThemMode.dark<br>
**3. Uji aplikasi dengan ukuran layar emulator yang berbeda.**<br>
Saya memakai Android fisik dikarenakan RAM penyimpanan saya hanya 8GB.<br>
**4. Tambahkan Semantics atau label yang bermakna pada elemen yang penting bagi screen reader.**
Tanpa Semantics, screen reader tetap bisa membaca teks yang ada, namun teks-teks tersebut dibaca sebagai elemen terpisah, misalnya "Assignments" dan "8" dibaca dua kali berurutan tanpa konteks bahwa keduanya saling berkaitan. Dengan Semantics(label: ...), seluruh child di dalamnya digabung menjadi satu unit semantic dengan label yang sudah disusun secara bermakna, sehingga screen reader membacanya sebagai satu kalimat utuh ("Assignments: 8"), bukan potongan-potongan info yang terpisah.
</blockquote>
</details>

<br>