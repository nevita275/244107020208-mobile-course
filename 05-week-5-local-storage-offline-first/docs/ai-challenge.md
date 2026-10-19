# AI Challenge: Local Storage & Offline First

## 1. Ringkasan

Aplikasi memiliki dua kebutuhan penyimpanan: preferensi tema yang kecil dan catatan lokal lebih dari 1.000 data yang perlu `dirty` flag untuk antrean sinkronisasi. Saya memilih SharedPreferences untuk preferensi dan sqflite untuk catatan karena skema SQLite yang ada sudah memiliki `dirty` dan `updated_at`, sementara kebutuhan terverifikasi saat ini dapat dilayani dengan query sederhana tanpa code generation.

## 2. Prompt yang Digunakan

Prompt AI Prompt Challenge berikut disalin apa adanya dari modul.

Tool yang tercatat pada sesi ini: Copilot SDK di VS Code. Tanggal prompt/verifikasi: 19 Oktober 2026.

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

## 3. Output Awal AI

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Kompleksitas query | Key-value sederhana, cocok untuk preferensi. | Akses key/box sederhana; filter daftar dikelola di aplikasi. | SQL `WHERE`, `ORDER BY`, transaksi; mapping dilakukan manual. | SQL/query builder Dart, mendukung filter dan join. |
| Relasi | Tidak untuk relasi data. | Relasi dikelola di kode aplikasi. | Mendukung relasi SQLite dan foreign key. | Relasi SQLite dengan API Dart bertipe. |
| Reaktivitas | Bukan stream query; UI mengelola perubahan state. | Box menyediakan stream perubahan. | Query biasa mengembalikan Future; refresh UI perlu dikelola. | Query dapat diamati sebagai stream dengan `watch()`. |
| Type-safety | Tipe nilai preferensi dasar. | Objek dapat diberi tipe; adapter diperlukan untuk model tertentu. | Hasil query berupa map yang dipetakan ke model. | Tabel dan query menghasilkan API bertipe melalui code generation. |
| Boilerplate | Minimal untuk beberapa key. | Rendah–sedang; inisialisasi dan adapter menambah pekerjaan. | Sedang; SQL, mapping, dan migrasi manual. | Lebih tinggi di awal karena generator; query sesudahnya lebih ringkas. |
| Testing | Menguji wrapper preferensi terpisah relatif sederhana. | Box dan adapter dapat diuji terpisah. | Repository dapat diuji dengan fake atau database pengujian. | Query bertipe dapat diuji dengan test executor; code generation perlu disiapkan. |

**Rekomendasi jawaban ini:** SharedPreferences untuk preferensi tema, dan Drift untuk catatan apabila prioritasnya adalah query bertipe serta pembaruan stream otomatis. Drift tetap memakai SQLite, tetapi menambah generator dan kompleksitas setup; sqflite merupakan pilihan lebih sederhana untuk CRUD yang query-nya langsung dan terbatas. Hive ringan untuk data key-value/objek, tetapi kurang sesuai jika aplikasi memerlukan query relasional.

Contoh skema catatan 1.000+ baris dengan antrean sinkronisasi:

```sql
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at INTEGER NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
);

CREATE INDEX idx_notes_updated_at ON notes(updated_at);
```

`updated_at` pada contoh ini adalah Unix timestamp milidetik; `dirty = 1` menandai perubahan lokal yang belum tersinkron. Query daftar dapat mengurutkan `updated_at DESC` dan memakai pagination. Ini adalah skema contoh jawaban saya, bukan bukti skema keluaran AI asli atau skema database yang diterapkan proyek.

## 4. Verifikasi (AI Verification Checklist)

Lima pertanyaan checklist berikut mengikuti modul.

### 4a. Apakah AI menempatkan daftar catatan di SharedPreferences?

- **Pertanyaan:** Apakah daftar catatan disarankan disimpan di SharedPreferences?
- **Temuan:** Dalam jawaban mandiri di bagian 3, SharedPreferences direkomendasikan hanya untuk preferensi; daftar catatan disimpan di database Drift/SQLite, bukan di SharedPreferences.
- **Bukti:** Bagian 3 memisahkan rekomendasi penyimpanan tema dan catatan, lalu memperlihatkan tabel SQLite `notes`. Ini memverifikasi jawaban yang disusun di dokumen ini, bukan keluaran AI asli yang sudah dihapus.

### 4b. Apakah skema AI mendukung antrean sync (`dirty` / `updated_at`) atau hanya CRUD polos?

- **Pertanyaan:** Apakah skema usulan memuat status sinkronisasi dan waktu pembaruan?
- **Temuan:** Skema contoh pada jawaban mandiri bagian 3 memiliki `body`, `updated_at INTEGER`, dan `dirty`; karena itu, skema tersebut mendukung penandaan baris yang perlu disinkronkan. Dibandingkan skema proyek, nama kolom isi dan dirty sama, tetapi tipe waktu berbeda. Keluaran AI asli sudah dihapus, sehingga tabel ini membandingkan jawaban mandiri yang terdokumentasi dengan project, bukan merekonstruksi keluaran terdahulu.

| Aspek | Skema contoh jawaban bagian 3 | Skema aktual proyek |
|---|---|---|
| Kolom isi | `body TEXT NOT NULL DEFAULT ''` | `body TEXT NOT NULL DEFAULT ''` (`week5_offline_notes/lib/data/local/db.dart:12–18`) |
| Flag dirty | Ada: `dirty INTEGER NOT NULL DEFAULT 0` | Ada: `dirty INTEGER NOT NULL DEFAULT 0` |
| Tipe waktu | `updated_at INTEGER NOT NULL` (Unix timestamp milidetik) | `updated_at TEXT NOT NULL`; [`note.dart`](../week5_offline_notes/lib/data/local/note.dart) memetakan `DateTime` ke/dari ISO-8601 |
| `created_at` | Tidak digunakan dalam contoh; pengurutan memakai `updated_at` | Tidak ada pada tabel `notes` |
| `cached_posts` | Tidak termasuk tabel notes pada contoh jawaban | Tabel terpisah: `id INTEGER PRIMARY KEY`, `payload TEXT NOT NULL`, `cached_at TEXT NOT NULL` |

Kolom `dirty` pada skema contoh memungkinkan aplikasi memilih baris yang belum tersinkron; bila kolom itu tidak ada, status tersebut harus disimpan di tempat lain. Repository proyek menghitung baris `dirty = 1` dan mengubahnya menjadi `0` pada proses sinkronisasi simulasi (`note_repository.dart:67–78`).

### 4c. Apakah klaim reaktivitas/stream pada jawaban bagian 3 didukung?

- **Pertanyaan:** Apakah klaim stream otomatis didukung dokumentasi resmi?
- **Temuan:** Dokumentasi Drift secara eksplisit menyatakan query dapat menjadi stream auto-updating melalui `watch()`. Dokumentasi Hive menyatakan `BoxBase.watch()` mengembalikan broadcast stream perubahan. Dokumentasi sqflite yang diperiksa memaparkan `query()` sebagai `Future<List<Map<String, Object?>>>` dan helper SQL; halaman API tersebut tidak mendokumentasikan stream query otomatis. Ini membedakan API yang terdokumentasi, bukan klaim bahwa sqflite tidak dapat dipadukan dengan state management atau mekanisme stream buatan aplikasi.
- **Bukti/sumber resmi, diakses 19 Oktober 2026:**
  - Drift, stream queries: <https://drift.simonbinder.eu/dart_api/streams/> — menjelaskan `.watch()` dan stream auto-updating.
  - Hive, `BoxBase.watch`: <https://pub.dev/documentation/hive/latest/hive/BoxBase/watch.html> — `Stream<BoxEvent>`.
  - sqflite, `DatabaseExecutor.query`: <https://pub.dev/documentation/sqflite/latest/sqflite/DatabaseExecutor/query.html> — signature `Future<List<Map<String, Object?>>> query(...)`; halaman ini tidak menunjukkan `.watch()` atau query stream.
  - Deskripsi paket sqflite: <https://pub.dev/packages/sqflite> — fitur yang tercantum meliputi transaksi, batch, dan helper CRUD.

Temuan dokumentasi di atas mendukung perbandingan pada jawaban mandiri bagian 3: Drift dan Hive menyediakan stream terkait perubahan, sedangkan helper query sqflite yang diperiksa mengembalikan Future.

### 4d. Apakah estimasi boilerplate pada jawaban bagian 3 masuk akal?

**Percobaan Drift terisolasi**

- **Pertanyaan:** Apakah perkiraan boilerplate/code generation Drift masuk akal untuk satu tabel minimal?
- **Temuan:** Percobaan instalasi dan code generation berhasil; Drift membutuhkan setup package generator dan menghasilkan file `.g.dart`. Ukuran generated cukup besar dibanding source minimal, tetapi hasil ini hanya mewakili satu tabel sederhana.
- **Bukti:** Perintah, source yang ditulis, elapsed time, jumlah/ukuran file, serta seluruh catatan error/peringatan dicantumkan di bawah berdasarkan output terminal.

Percobaan dijalankan di `$env:TEMP\drift_trial` (Windows), di luar repository dan bukan di project tugas. Urutan perintah:

```text
flutter create drift_trial
flutter pub add drift drift_flutter
flutter pub add --dev drift_dev build_runner
dart run build_runner build
```

Saya menambahkan satu file `lib/database.dart` dengan tabel `Notes` minimal (`id`, `title`, `body`, `updatedAt`, `dirty`) dan kelas database `AppDatabase`. Source tersebut berisi 15 baris kode menurut pengukuran `Get-Content | Measure-Object -Line`.

Hasil yang tercatat:

| Pengukuran | Hasil |
|---|---|
| Waktu menjalankan `dart run build_runner build` | Mulai 21:23:34 WIB; 117,03 detik elapsed (output build_runner menyatakan 99 detik untuk build AOT dan builder; waktu selesai tidak dicatat sebagai timestamp terpisah) |
| Output build_runner | `Built with build_runner/aot in 99s; wrote 8 outputs.` |
| File Dart `.g.dart` di `lib` | 1 file: `database.g.dart` |
| Ukuran file `.g.dart` | 16.543 byte, 523 baris |
| Baris kode tulisan tangan | 15 baris pada satu file untuk tabel dan database |
| Error/peringatan | Tidak ada error atau peringatan build yang tampil. Pub menampilkan pemberitahuan bahwa 11 lalu 14 paket memiliki versi lebih baru yang tidak sesuai constraint, bukan kegagalan instalasi. |
| Pembersihan | Folder `$env:TEMP\drift_trial` dihapus setelah pengukuran; pemeriksaan akhir `Test-Path` menghasilkan `False`. |

Perintah `flutter create` dan kedua `flutter pub add` berhasil dengan exit code 0. Code generation Drift berhasil, tetapi membutuhkan package generator dan langkah build tambahan. Pengukuran 15 baris ini hanya untuk satu tabel sederhana; bukan ukuran implementasi aplikasi penuh.

**Pembanding sqflite pada project**

Di project yang ada, `Get-ChildItem` menghasilkan ukuran berikut:

| File | Ukuran |
|---|---:|
| `week5_offline_notes/lib/data/local/note.dart` | 999 byte |
| `week5_offline_notes/lib/data/local/db.dart` | 760 byte |
| `week5_offline_notes/lib/data/repositories/note_repository.dart` | 4.361 byte |

Project menggunakan SQL dan mapping model secara manual, dan tidak memiliki langkah code generation Drift. Ukuran repository diukur ulang setelah fitur update ditambahkan dan mencakup provider Riverpod serta operasi repository, sehingga angka ini bukan perbandingan satu-banding-satu dengan output generator Drift. Bukti percobaan mendukung bahwa Drift menambah langkah generator dan menghasilkan file generated yang jauh lebih besar daripada schema tulisan tangan; percobaan ini tidak mengukur waktu atau boilerplate total implementasi CRUD lengkap.

### 4e. Keputusan final

- **Pertanyaan:** Pilihan mana yang paling sesuai setelah melihat kebutuhan dan bukti?
- **Temuan:** Saya memilih SharedPreferences untuk preferensi tema dan sqflite untuk catatan. Alasan dan trade-off dijabarkan pada bagian 6.
- **Bukti:** Skema aktual di `db.dart`, implementasi repository, percobaan code generation bagian 4d, dan tes repository/provider di `test/note_test.dart`.

## 5. Tabel Perbandingan Final

Sel yang merevisi perbandingan pada draft dokumentasi sebelumnya ditandai dengan **“dikoreksi: alasan”**. Karena output AI asli sudah dihapus, label koreksi ini bukan klaim perbandingan langsung terhadap output historis. Baris dukungan dirty flag disertakan karena sinkronisasi merupakan kebutuhan aplikasi ini.

Fakta kemampuan paket pada tabel merujuk dokumentasi resmi: [SharedPreferences](https://pub.dev/packages/shared_preferences) mencantumkan tipe nilai yang didukung; [Hive](https://pub.dev/packages/hive) menjelaskan model key-value dan adapter; [sqflite](https://pub.dev/packages/sqflite) menjelaskan helper CRUD, transaksi, dan batch; [Drift](https://pub.dev/packages/drift) menjelaskan query SQL/Dart, relasi, type-safety, dan reaktivitas. Dukungan foreign key merupakan kemampuan SQLite yang dijelaskan pada dokumentasi [SQLite Foreign Key Constraints](https://www.sqlite.org/foreignkeys.html). Tabel tidak menyamakan kemampuan paket dengan hasil percobaan aplikasi ini.

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
|---|---|---|---|---|
| Kompleksitas query | Key-value untuk preferensi; bukan API query koleksi catatan. | Key-value/box; query SQL dan relasi bukan fokus paket. | SQL langsung untuk `WHERE`, urutan, agregasi, transaksi; pemetaan query dikelola aplikasi. | SQL atau query builder Dart, termasuk filter dan join. |
| Kebutuhan relasi | Tidak menyediakan relasi tabel; cocok untuk nilai preferensi mandiri. | Tidak menyediakan foreign key relasional; hubungan dikelola aplikasi. | Relasi dan foreign key SQLite; deklarasi serta query ditulis manual. | Relasi SQLite dengan API query bertipe; deklarasi awal lebih banyak. |
| Reaktivitas (stream) | API penyimpanan preferensi bukan query stream database; UI perlu mengelola state perubahan. | `BoxBase.watch()` mengembalikan broadcast stream perubahan. | `db.query()` menghasilkan `Future<List<Map<String, Object?>>>`, bukan stream query otomatis pada API yang dirujuk (**dikoreksi: API resmi sqflite yang diperiksa berbentuk Future; refresh/invalidation perlu dikelola aplikasi**). | Query dapat menjadi auto-updating stream lewat `watch()` menurut dokumentasi Drift. |
| Type-safety | Tipe nilai preferensi dasar, seperti bool dan String; bukan model/query bertipe. | Box dapat diberi tipe objek; adapter diperlukan untuk model objek khusus. | Hasil helper query berupa map dan perlu dipetakan ke model secara manual (**dikoreksi: hasil query bukan model Note bertipe secara otomatis**). | Tabel dan query menghasilkan API Dart bertipe melalui code generation. |
| Ukuran boilerplate | Kecil untuk sejumlah kecil key. | Perlu inisialisasi box dan adapter/serialisasi untuk model khusus. | SQL, mapping, dan migrasi dikelola manual; tiga file terkait di project berukuran 760, 999, dan 4.361 byte (**dikoreksi: angka repository sebelumnya 2.971 byte diukur sebelum UPDATE ditambahkan**). | Percobaan satu tabel: 15 baris tulisan tangan, 1 file generated 16.543 byte/523 baris, build 117,03 detik (**dikoreksi: angka ini hasil satu percobaan minimal, bukan estimasi universal**). |
| Kemudahan testing | Belum diuji di project ini; tidak ada tes `PrefsRepository` pada file tes yang diperiksa. | Belum diuji; project tidak memakai Hive atau adapter. | Repository menerima `openDb`; tes memakai `FakeNoteRepository` melalui provider override untuk update (**dikoreksi: yang teruji adalah validasi id dan alur fake repository/provider, bukan database in-memory atau SQLite nyata**). | Belum diuji; percobaan hanya mengukur code generation, bukan query atau test executor. |
| Dukungan dirty flag / antrean sync | Dapat menyimpan preferensi boolean, tetapi bukan pilihan yang dipakai untuk daftar catatan. | Dapat menyimpan field `dirty` pada objek di box, tetapi pencarian/pembaruan antrean dikelola aplikasi. | Kolom `dirty INTEGER` dipakai project; repository membaca dan menandainya setelah sync, serta menandai catatan baru/diubah sebagai dirty. | Dapat memodelkan flag boolean dan memfilter query bertipe; belum diterapkan pada project ini. |

## 6. Keputusan Final dan Trade-off

**Saya memilih SharedPreferences untuk preferensi tema dan sqflite untuk catatan.** Preferensi proyek berupa nilai kecil (`dark_mode` dan waktu pembukaan terakhir; `prefs.dart:4–29`), sedangkan kebutuhan catatan adalah CRUD lokal, pengurutan berdasarkan `updated_at`, dan penandaan `dirty` untuk sinkronisasi. Repository sekarang menyediakan baca, tambah, update, dan hapus; `updateNote` meminta ID, memperbarui baris berdasarkan ID, menetapkan waktu sekarang dan `dirty: true`, serta melaporkan ID yang tidak ditemukan (`note_repository.dart:39–69`). Daftar diurutkan berdasarkan `updated_at` terbaru (`note_repository.dart:13–16`). Skema aktual mencakup `updated_at` dan `dirty` (`db.dart:12–18`).

Saya menerima trade-off bahwa sqflite tidak menyediakan query stream otomatis pada API yang diperiksa; aplikasi perlu mengelola pembaruan state secara eksplisit. Notifier mengganti item dalam list baru tanpa memutasi list sebelumnya, mengurutkan hasil berdasarkan waktu baru, dan menginvalidasi `dirtyCountProvider` setelah update berhasil (`note_repository.dart:103–132`). UI membuka dialog edit saat item diketuk; dialog menginisialisasi controller dari judul/isi saat ini, menolak judul kosong, lalu membuang controller saat dialog ditutup (`notes_page.dart:106–141, 220–302`). Setelah sinkronisasi, provider catatan dan dirty count juga diinvalidasi (`providers.dart:186–187`). Ini state management berbasis invalidation, bukan stream database otomatis.

Testing memverifikasi bahwa update dengan ID null melempar `ArgumentError` sebelum database dibuka, dan `NotesNotifier.updateNote` memanggil fake repository lalu state memuat judul/isi baru serta `dirty == true` (`test/note_test.dart:54–116`). Fake dipasang melalui override provider; ini bukan integrasi dengan database SQLite sungguhan.

Saya mempertimbangkan Drift bila aplikasi berkembang membutuhkan banyak relasi, query kompleks, atau stream query otomatis. Trade-off Drift yang terlihat pada percobaan adalah ketergantungan generator dan langkah code generation tambahan; manfaat query bertipe/reaktif belum diperlukan oleh kebutuhan dan implementasi saat ini.

## 7. Skema Final

Berikut SQL yang benar-benar dipakai oleh `openNotesDb()` di `week5_offline_notes/lib/data/local/db.dart`. Tidak ada `created_at` pada tabel `notes`; `updated_at` disimpan sebagai teks ISO-8601 dan model menerjemahkannya menjadi `DateTime`. Operasi update menulis `title`, `body`, `updated_at`, dan `dirty` ke baris dengan `WHERE id = ?`; skema tidak diubah untuk menambahkan fitur UPDATE.

```sql
CREATE TABLE notes(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,
  dirty INTEGER NOT NULL DEFAULT 0
)

CREATE TABLE cached_posts(
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  cached_at TEXT NOT NULL
)
```

**Perbaikan dokumentasi untuk 1.000+ baris (belum diterapkan pada kode):**

```sql
CREATE INDEX idx_notes_updated_at ON notes(updated_at);
```

Indeks tersebut dapat membantu query `ORDER BY updated_at DESC` saat tabel bertambah. Untuk daftar panjang, gunakan pagination (`LIMIT`/`OFFSET` atau keyset pagination). Saat menambahkan indeks, versi database perlu dinaikkan dan migrasi indeks ditambahkan pada `onUpgrade`; kode saat ini memakai `version: 1` dan belum memiliki callback `onUpgrade` (`db.dart:5–10`). Indeks dan pagination ini adalah rekomendasi, belum diterapkan.

## 8. Hasil Testing

### `flutter analyze`

![](../screenshots/flutteranalyze.png)

### `flutter test` — run 1,2,3

![](../screenshots/fluttertest.png)

