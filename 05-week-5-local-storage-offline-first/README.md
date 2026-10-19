## NAMA  : NEVITA TRIYA YULIANA <br>
## KELAS : TI-3F <br>
## ABSEN : 20 <br>


# Local Storage & Offline First

<details>
<summary><h2>Praktikum 1: SharedPreferences</h2></summary>
<br>

<blockquote>

| Tampilan hasil mode light | Tampilan hasil model dark |
|---|---|
| ![](screenshots/run1.png) | ![](screenshots/run2.png) |
</blockquote>
</details>

<br>


<details>
<summary><h2>Praktikum 2: SQLite dan repository catatan</h2></summary>
<br>
<blockquote>

| Tampilan catatan kosong | Tampilan tambah catatan | Tampilan catatan keisi 1 |
|---|---|---|
| ![](screenshots/run3.png) |![](screenshots/run4.png) | ![](screenshots/run5.png)
</blockquote>
</details>

<br>

<details>
<summary><h2>Praktikum 3: Cache-first dan antrean sync</h2></summary>
<br>
<blockquote>

| Tampilan run | Tampilan tersinkron | 
|---|---|
| ![](screenshots/run6.png) | ![](screenshots/run7.png) |

<br>

| Tampilan catatan saat mode pesawat | Tampilan post saat mode pesawat |
|---|---|
| <img src="screenshots/run8.png" width="600"> | <img src="screenshots/run9.png" width="600"> |
</blockquote>
</details>

<br>

<details>
<summary><h2>AI Challenge</h2></summary>
<br>
<blockquote>

Bagian ini membandingkan SharedPreferences, Hive, sqflite, dan Drift untuk
aplikasi Offline Notes. AI merekomendasikan SharedPreferences untuk preferensi
dan Drift untuk catatan. Keputusan akhir saya: **SharedPreferences + sqflite**,
karena kebutuhan catatan hanya CRUD dengan flag `dirty` untuk antrean sinkronisasi,
tidak memerlukan code generation, dan mudah diuji dengan repository palsu.

Temuan verifikasi singkat:
- AI tidak menaruh daftar catatan di SharedPreferences (benar).
- Skema usulan AI tidak memiliki kolom `dirty`, sehingga tidak mendukung antrean
  sinkronisasi; skema yang saya pakai menambahkannya.
- Klaim stream dan estimasi boilerplate diverifikasi lewat dokumentasi resmi dan
  percobaan instalasi Drift.

</blockquote>
</details>

<br>
