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
Ditambahkan setelah baris Kelas, mengikuti pola Row + Expanded yang sama: label di kiri dibungkus Expanded agar mengambil sisa ruang dan mendorong nilai ke kanan, sedangkan nilai di kanan tidak dibungkus Expanded sehingga lebarnya mengikuti panjang teksnya sendiri.
</blockquote>
</details>

<br>

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
Ditambahkan setelah baris Kelas, mengikuti pola Row + Expanded yang sama: label di kiri dibungkus Expanded agar mengambil sisa ruang dan mendorong nilai ke kanan, sedangkan nilai di kanan tidak dibungkus Expanded sehingga lebarnya mengikuti panjang teksnya sendiri.
</blockquote>
</details>

<br>