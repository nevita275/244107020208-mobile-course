# Week 7: Clean Architecture feature-first

## Pemetaan file lama ke tujuan

| File lama di Week 5 | Tujuan di Week 7 | Keputusan |
|---|---|---|
| `lib/data/local/note.dart` | `features/notes/domain/entities/note.dart` dan `features/notes/data/models/note_model.dart` | Dipecah menjadi entity murni dan mapping SQLite. |
| `lib/data/repositories/note_repository.dart` | `features/notes/domain/repositories/note_repository.dart`, `features/notes/data/repositories/note_repository_impl.dart`, `features/notes/presentation/providers/notes_providers.dart` | Kontrak, implementasi, dan state/DI dipisah. |
| `lib/data/sync.dart` | `features/notes/domain/usecases/sync_notes.dart`, `features/notes/domain/usecases/resolve_conflict.dart` | Sinkronisasi simulasi dan aturan konflik menjadi kode domain. |
| `lib/data/post.dart` | `features/posts/domain/entities/post.dart`, `features/posts/data/models/post_model.dart` | Entity dan mapping JSON dipisah. |
| `lib/data/post_repository.dart` | `features/posts/domain/repositories/post_repository.dart`, `features/posts/data/repositories/post_repository_impl.dart` | Kontrak/domain dipisahkan dari Dio, cache SQLite dan JSON. |
| Bagian posts di `lib/data/providers.dart` | `features/posts/domain/usecases/refresh_posts.dart`, `features/posts/presentation/providers/posts_providers.dart` | Refresh jaringan/cache menjadi use case; provider state tetap di presentation. |
| Bagian notes dan sync di `lib/data/providers.dart` | `features/notes/presentation/providers/notes_providers.dart` | Wiring dan state notes dipindah ke presentation. |
| `lib/pages/notes_page.dart` | `features/notes/presentation/pages/notes_page.dart` | Halaman notes dipindah ke feature. |
| `lib/pages/posts_page.dart` | `features/posts/presentation/pages/posts_page.dart` | Halaman posts dipindah ke feature. |
| Pemformatan tanggal dari `lib/pages/settings_page.dart` dan banner Posts | `lib/core/format.dart` | Dipindah ke fungsi Dart murni dan diuji terpisah. |
| `lib/data/local/db.dart` | Tetap `lib/data/local/db.dart` | Database opener digunakan bersama catatan dan cache Posts. |
| `lib/data/prefs.dart`, `lib/pages/settings_page.dart` | Tetap di lokasi semula | Preferensi bukan feature yang direfactor pada tugas ini. |
| `test/note_test.dart`, `test/sync_test.dart`, `test/posts_provider_test.dart` | Test Week 7 dengan import package Week 7 dan fake domain repository | Tes behavior dipindahkan dan diperbarui mengikuti kontrak baru. |

Folder project Week 5 asli tidak dimodifikasi oleh deliverable Week 7.

## Usulan vs keputusan final

| Area | Usulan | Keputusan final | Alasan |
|---|---|---|---|
| Struktur | Feature-first untuk notes dan Posts | `features/{notes,posts}/{presentation,domain,data}` | Keduanya fitur yang sudah ada dan dapat dipahami tanpa mencampur lapisan. |
| Entity/model | Entity murni; mapping di model | `Note`/`Post` di domain, `NoteModel`/`PostModel` di data | Domain tidak membawa detail nama kolom, JSON, atau format penyimpanan. |
| Kontrak repository | Interface di domain | `NoteRepository` dan `PostRepository` berada di domain; implementasi di data | Data bergantung ke abstraksi domain, bukan sebaliknya. |
| Operasi | Use case untuk operasi bisnis | `GetNotes`, `SyncNotes`, dan `RefreshPosts`; CRUD satu-baris tetap langsung dari notifier | Sync dan refresh mengorkestrasi beberapa operasi; CRUD sederhana tidak perlu lapisan tambahan. |
| Wiring | Riverpod tanpa package DI tambahan | Provider repository, use case, dan state tiap fitur ada di presentation | Sesuai pola project dan mudah dioverride dengan fake pada test. |
| Cakupan | Migrasikan fitur yang telah ada | Notes dan Posts dimigrasikan; preferensi tetap memakai struktur Week 5 | Memenuhi pola fitur kedua tanpa mengubah fitur preferensi. |
| Error | Failure eksplisit dari repository | Akses SQLite/jaringan mengembalikan `Failure`; provider meneruskannya ke state async | UI tidak perlu mengetahui exception SQLite, Dio, atau package database. |

Struktur hasil:

```text
lib/
├── core/failures.dart
├── features/notes/
│   ├── data/
│   │   ├── models/note_model.dart
│   │   └── repositories/note_repository_impl.dart
│   ├── domain/
│   │   ├── entities/note.dart
│   │   ├── repositories/note_repository.dart
│   │   └── usecases/
│   └── presentation/
│       ├── pages/notes_page.dart
│       └── providers/notes_providers.dart
├── features/posts/
│   ├── data/
│   │   ├── models/post_model.dart
│   │   └── repositories/post_repository_impl.dart
│   ├── domain/
│   │   ├── entities/post.dart
│   │   ├── repositories/post_repository.dart
│   │   └── usecases/refresh_posts.dart
│   └── presentation/providers/posts_providers.dart
└── providers/app_providers.dart
```

## Dependency rule

Hasil pemeriksaan pada `lib/features/notes/presentation` dan `lib/core`:

1. Presentation tidak mengakses `Dio`, SQLite, secure storage, SharedPreferences,
   atau JSON mentah.
2. Domain dan core tidak mengimpor Flutter, Dio, SQLite, atau Firebase.
3. Mapping `toMap`/`fromMap` dan JSON hanya berada di model data.

Jalankan dari folder `07-week-7-clean-architecture`:

```powershell
rg "Dio\(|openDatabase|getDatabasesPath|FlutterSecureStorage|SharedPreferences\.getInstance|jsonDecode" lib/features/notes/presentation lib/features/posts/presentation lib/pages
rg "import 'package:flutter|import 'package:dio|import 'package:sqflite|import 'package:firebase" lib/features/notes/domain lib/features/posts/domain lib/core
rg "toMap|fromMap|toJson|fromJson" lib/features/notes/domain lib/features/posts/domain
flutter analyze
flutter test
```

Semua pencarian `rg` di atas menghasilkan nol temuan. Output perintah disimpan
di [verification.md](verification.md). `flutter analyze` dan `flutter test`
dijalankan di folder Week 7. Screenshot baseline dan status screenshot sesudah
refactor dicatat di [verification.md](verification.md).

## Batasan dan trade-off

- Preferensi tetap berada di struktur Week 5 lama; migrasi tersebut tidak
  mencakup semua kode aplikasi.
- Sinkronisasi masih simulasi lokal: tidak ada pengiriman data ke server.
- Clean Architecture menambah file dan navigasi folder. Untuk CRUD kecil, use
  case satu-baris tidak wajib; gunakan langsung repository dari notifier sampai
  aturan bisnis atau orkestrasi membuat use case bermanfaat.
- Tidak ada database sungguhan pada pengujian domain/use case; kontraknya diuji
  melalui `FakeNoteRepository`.
- Parser route murni diuji terpisah. Project memakai Navigator yang sudah ada
  dan belum memakai deep-link routes untuk entity ID.
