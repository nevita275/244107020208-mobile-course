## NAMA  : NEVITA TRIYA YULIANA <br>
## KELAS : TI-3F <br>
## ABSEN : 20 <br>


# Navigation & State Management

<details>
<summary><h3>2. Konsep navigasi dan GoRouter</h3></summary>
<br>
<blockquote>

## flutter pub add go_route
![](screenshots/flutterpubaddgoroute.png)<br>
## Susun struktur folder:<br>
![](screenshots/strukturfolder.png)<br>
## 1. Definisikan router di lib/main.dart:<br>
![](screenshots/main.png)<br>
## 2. Halaman Home (lib/pages/home_page.dart):<br>
![](screenshots/homepage.png)<br>
## 3. Halaman Detail (lib/pages/detail_page.dart)<br>
![](screenshots/detailpage.png)<br>
## 4. Jalankan dan amati. Buka item, lalu tekan tombol back sistem. Perhatikan bahwa path berubah mengikuti layar aktif, path yang sama juga dapat diakses langsung tanpa melewati Home. Inilah keunggulan router deklaratif dibanding Navigator 1.0.<br>
| Tampilan hasil run | Tampilan Detail |
|---|---|
| ![](screenshots/run.png) | ![](screenshots/run1.png) |
</blockquote>
</details>

<br>

<details>
<summary><h3>3. State management dengan Riverpod</h3></summary>
<br>
<blockquote>

## flutter pub add flutter_riverpod
![](screenshots/flutterriverpod.png)<br>
## 1. Bungkus aplikasi dengan ProviderScope di lib/main.dart:<br>
![](screenshots/maintodo.png)<br>
## 2. Buat state dan provider (lib/providers/todo_provider.dart):<br>
![](screenshots/todoprovider.png)<br>
## 3. Tampilkan dengan ConsumerWidget (lib/pages/todo_page.dart):<br>
![](screenshots/todopage1.png)<br>
![](screenshots/todopage2.png)<br>
## 4. Hasil Run<br>
| Tampilan hasil run | Tampilan Tambah |
|---|---|
| ![](screenshots/run2.png) | ![](screenshots/runtambahtodo.png) |

<br>

| Tampilan Sudah Selesai/Dicentang | Tampilan Hapus |
|---|---|
| ![](screenshots/rundonetodo.png) | ![](screenshots/runhapustodo.png) |
</blockquote>
</details>

<br>