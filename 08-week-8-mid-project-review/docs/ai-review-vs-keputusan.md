# AI Review vs Keputusan

## Prompt

```text
Review PR Flutter ini sebagai senior Flutter dev.
Konteks: feature-first Clean Architecture (presentation -> domain <- data),
Riverpod, GoRouter, SQLite + Dio.
Fokus: kebenaran, arsitektur, dan test. Abaikan style.
Berikan 5 temuan teratas + level (blocker/saran)
+ alasan + usulan potongan kode perbaikan.
```

## Batas dan hasil review

Review ini dilakukan AI atas permintaan author terhadap kode project Week 8
yang merupakan lanjutan Week 7. Ini bukan review sejawat dan bukan review
perubahan pada Pull Request GitHub; PR Week 8 belum dibuat. Prompt menyebut
GoRouter, tetapi aplikasi memakai Navigator. Perbedaan tersebut tidak dianggap
bug tanpa kebutuhan migrasi.

Lima poin berikut adalah temuan dan kandidat yang diverifikasi. Tidak semua
kandidat AI merupakan cacat; hal yang ditolak atau dipastikan bukan bug dicatat
agar tidak diterapkan mentah-mentah.

| # | Level | Temuan/kandidat | Bukti dan keputusan |
|---|---|---|---|
| 1 | Saran penting | Jika operasi add/edit/delete gagal, pertahankan daftar catatan dan tampilkan umpan balik kegagalan operasi. | **Benar, belum diperbaiki.** `NotesNotifier.add/updateNote/remove` menggunakan `AsyncValue.guard`, sehingga kegagalan membuat state `AsyncError`. `NotesPage` merender satu tampilan error untuk seluruh `notesProvider`; daftar yang sebelumnya tampil hilang dan tidak ada pesan spesifik operasi. Usul: pertahankan nilai sebelumnya dan tampilkan snackbar yang informatif. Tambahkan test notifier/widget untuk memastikan data tetap terlihat saat repository gagal. |
| 2 | Saran test | Tambahkan test bahwa judul yang hanya berisi spasi ditolak. | **Gap test terkonfirmasi; validasi implementasi sudah benar.** Validator memeriksa `value.trim().isEmpty`, tetapi [`test/notes_page_test.dart`](../test/notes_page_test.dart) saat ini hanya menguji judul kosong. Tambahkan kasus whitespace untuk mencegah regresi. |
| 3 | Saran (ditolak) | Pindahkan wiring repository karena provider Notes mengimpor implementasi data dan pembuka SQLite. | **Bukan pelanggaran dependency rule pada konteks ini.** Provider dipakai sebagai composition root; UI tidak membuat database/repository sendiri dan domain tidak mengimpor Flutter, Dio, atau SQLite. Memindahkan wiring tanpa kebutuhan tidak memperbaiki arah dependency domain. |
| 4 | Saran (ditolak) | Migrasikan Navigator ke GoRouter karena GoRouter disebut di prompt. | **Bukan temuan.** Project Week 7 yang direview memang memakai Navigator. Prompt memberikan konteks, bukan mandat migrasi router; tidak ada bug yang dibuktikan oleh penggunaan Navigator. |
| 5 | Verifikasi positif | Periksa apakah refresh Posts yang gagal menghilangkan data cache. | **Tidak ditemukan cacat pada jalur yang diuji.** `PostsNotifier.refresh` mempertahankan `previous` saat fetch gagal, dan test `refresh gagal mempertahankan cache dan menyampaikan failure` memverifikasi posts lama tetap tersedia serta failure diteruskan. |

## Bukti test yang sudah diterapkan

Widget test untuk judul kosong memakai interaksi form pengguna:

```dart
await tester.tap(find.widgetWithText(FloatingActionButton, 'Tambah'));
await tester.pumpAndSettle();
await tester.tap(find.widgetWithText(FilledButton, 'Tambah'));
await tester.pumpAndSettle();
expect(find.text('Judul wajib diisi'), findsOneWidget);
```

Test itu sudah lulus dalam pemeriksaan Week 8 dan memastikan catatan tidak
ditambahkan saat judul kosong.

## Contoh tindak lanjut yang diusulkan

Untuk temuan 1, perubahan perlu mempertahankan data sebelumnya dan meneruskan
error ke UI agar dapat ditampilkan sebagai snackbar. Contoh pola yang perlu
diadaptasi dan diuji (belum diterapkan):

```dart
final previousNotes = state.value ?? const <Note>[];
try {
  // Jalankan operasi repository dan perbarui state hanya saat sukses.
} on Failure catch (failure, stackTrace) {
  state = AsyncData(previousNotes);
  Error.throwWithStackTrace(failure, stackTrace);
}
```

Temuan 1 belum diperbaiki dan harus dipertimbangkan sebelum menyatakan review
selesai. Hasil pemeriksaan saat ini: `flutter analyze` lulus dan seluruh 23
test lulus. Tidak ada persetujuan reviewer manusia; AI tidak dapat memberi
Approve GitHub.
