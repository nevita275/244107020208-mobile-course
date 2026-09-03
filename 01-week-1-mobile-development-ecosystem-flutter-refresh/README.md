## NAMA  : NEVITA TRIYA YULIANA <br>
## KELAS : TI-3F <br>
## ABSEN : 20 <br>


## Mobile Development Ecosystem & Flutter Refresh

<details>
<summary><h3>4. Menyiapkan environment</h3></summary>
<br>
<blockquote>

## flutter --version
![](screenshots/flutterversion.png)  
## flutter doctor
![](screenshots/flutterdoctor.png)  
## flutter doctor --android-licenses
Saya sempat dapat warning adi flutter doctor --android-licenses, sempat coba downgrade cmdline-tools, ternyata itu known bug, dan solusinya cukup lanjut flutter run karena license terhandle otomatis saat build <br>
![](screenshots/flutterlicenses.png)
</blockquote>
</details>

<br>

<details>
<summary><h3>5. Praktikum: aplikasi Flutter pertama</h3></summary>
<br>
<blockquote>

## Buat Project flutter
![](screenshots/projectflutter.png)
## Menggunakan USB
![](screenshots/usb.png)
## fultter run
![](screenshots/fultterrun.png)
## Code
![](screenshots/code.png)
## Hasil run
![](screenshots/run.png)
</blockquote>
</details>

<br>

<details>
<summary><h3>6. Tugas dan Refleksi</h3></summary>
<br>
<blockquote>

## Penambahan NIM dan Asal Kampus
![](screenshots/tugas.png)
## Hasil run
![](screenshots/runtugas.png)
## Refleksi
**Kapan native lebih tepat daripada cross-platform?** <br>
Native lebih unggul kalau butuh performa maksimal (game berat, editing video/audio real-time), akses API/hardware spesifik OS yang belum didukung baik oleh Flutter (misal fitur eksperimental terbaru dari Android/iOS), atau aplikasi yang harus sangat menyatu dengan look-and-feel platform tertentu.<br><br>
**Bagaimana perubahan state berhubungan dengan widget tree dan UI deklaratif?**<br>
Di Flutter, UI itu "fungsi dari state" tidak memanipulasi tampilan secara langsung (seperti setText() di native), tapi mendeskripsikan bagaimana UI seharusnya terlihat berdasarkan data saat ini. Saat state berubah (misal lewat setState()), Flutter membangun ulang (rebuild) widget tree yang terpengaruh, lalu membandingkan dengan tree sebelumnya (diffing), dan hanya me-render bagian yang benar-benar berubah.<br><br>
**Kenapa commit kecil dengan pesan jelas bermanfaat?**<br>
Memudahkan tracing kapan sebuah bug muncul (git bisect), memudahkan reviewer/rekan tim memahami perubahan tanpa harus baca ratusan baris sekaligus, dan riwayat commit yang rapi jadi bukti proses kerja yang bisa dinilai (bagus untuk portfolio karena menunjukkan cara berpikir, bukan cuma hasil akhir).

</blockquote>
</details>

<br>



