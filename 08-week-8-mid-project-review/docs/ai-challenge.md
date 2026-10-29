# AI Challenge

## Prompt yang diberikan

```text
Project Flutter saya: aplikasi Week 5 Offline Notes (CRUD catatan SQLite,
preferensi SharedPreferences, Posts cache-first dengan Dio).
Kondisi kini: model catatan masih memuat mapping SQLite, repository catatan
mencampur implementasi dengan provider, dan posts menggunakan model/repository
serta provider di folder data.

Tugas:
1. Usulkan struktur feature-first Clean Architecture untuk notes dan Posts.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah, pecah, atau tetap).
3. Tandai bagian yang over-engineering untuk CRUD sederhana dan kapan use case
   diperlukan dibanding repository langsung.
4. Tunjukkan wiring dependency injection menggunakan Riverpod tanpa package DI.
5. Jelaskan trade-off, error/failure, arah dependency, dan cara menguji use case
   dengan repository palsu tanpa SQLite atau jaringan.
Jangan menambah fitur bisnis baru dan jangan mengubah folder project Week 5.
```

## Output AI awal

1. Buat `features/notes` dan `features/posts`, masing-masing dengan
   `presentation`, `domain`, dan `data`.
2. Pisahkan `Note`/`Post` entity yang tidak bergantung framework dari model
   data. Mapping SQLite/JSON hanya dilakukan oleh model di data.
3. Letakkan interface repository pada domain dan implementasi SQLite/Dio di
   data. Kontrak mengembalikan hasil sukses atau `Failure` agar error sumber
   data tidak menjadi detail implementasi UI.
4. Pindahkan provider/notifier dan halaman per fitur ke presentation.
   Composition root Riverpod menyediakan implementasi ke kontrak dan
   menginjeksikan repository ke use case.
5. Gunakan `GetNotes` untuk memuat notes, `SyncNotes` untuk mengorkestrasi
   hitung dirty + mark-synced, dan `RefreshPosts` untuk fetch + menyimpan cache.
   CRUD satu operasi tetap boleh memanggil repository langsung dari notifier;
   class use case satu-baris untuk setiap CRUD akan menambah boilerplate tanpa
   manfaat berarti.
6. Uji use case melalui `FakeNoteRepository`/`FakePostRepository`. Pertahankan
   cache-first, offline behavior, dan state UX yang ada. Verifikasi dengan grep,
   analyzer, tes, dan uji manual UI.

## Usulan dibanding keputusan final

| Area | Usulan AI | Keputusan final | Trade-off |
|---|---|---|---|
| Fitur | Pisahkan Notes dan Posts | Keduanya dimigrasikan; preferensi tetap di root lama | Cakupan memenuhi fitur kedua tanpa memperluas refactor ke preferensi. |
| Repository | Interface di domain | `NoteRepository` dan `PostRepository` ada di domain; impl ada di data | Domain bisa dites tanpa plugin; kontrak record menambah sedikit tipe boilerplate. |
| Use case | Pakai untuk orkestrasi | Get, sync, dan refresh memiliki use case; CRUD langsung ke repository | Tidak membuat kelas add/update/delete satu-baris. |
| Error | Failure hasil repository | SQLite/Dio memetakan error ke `LocalFailure`/`NetworkFailure` | UI tetap menerima AsyncError, tetapi pesannya berasal dari Failure yang ramah pengguna. |
| DI | Riverpod tanpa package baru | Provider tiap feature di presentation | Sederhana dan mudah dioverride, dengan provider file sebagai composition root. |
| Shared DB | Satu opener dipakai beberapa feature | `openNotesDb` tetap di `lib/data/local/db.dart` | Database helper masih lintas fitur; pemisahan penuh DB dapat dilakukan bila migrasi schema berkembang. |
| Navigation | Tidak perlu router baru | Pertahankan Navigator yang sudah ada; helper parser murni dites terpisah | Tidak menambah GoRouter atau mengubah alur navigasi yang sudah berfungsi. |

## Pertanyaan verifikasi

- Repository contract berada di domain dan impl berada di data: **ya**.
- Domain bebas Flutter, Dio, sqflite, Firebase, dan mapping: **ya**, diperiksa
  dengan pencarian kode.
- Use case satu baris untuk seluruh operasi CRUD: **tidak**. `GetNotes` dipilih
  sebagai operasi query yang diminta; sinkronisasi dan refresh punya orkestrasi.
- Entity bebas mapping: **ya**.
- Wiring DI melalui provider: **ya**.
- Week 5 tetap utuh dan folder hasil berada di Week 7: **ya**.

Output ini merupakan usulan AI untuk prompt di atas; keputusan final beserta
pemetaan file konkret ada di [clean-architecture.md](clean-architecture.md).
