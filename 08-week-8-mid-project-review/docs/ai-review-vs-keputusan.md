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

## Batas review

Belum ada PR Week 8. Review awal berikut memeriksa salinan kode Week 7 di
project ini; bukan review PR sejawat. Bukti merujuk source dan test lokal, dan
setiap usulan perlu dinilai oleh author sebelum diterapkan.
Prompt codelab menyebut GoRouter, tetapi aplikasi ini memakai Navigator; review
tidak menganggap ketiadaan GoRouter sebagai bug.

## Temuan awal dan keputusan

| # | Level | Usulan AI | Bukti | Keputusan author |
|---|---|---|---|---|
| 1 | Saran | Tambahkan widget test untuk memastikan judul kosong/spasi ditolak dan dialog tidak mengembalikan draft. | Validator ada di `lib/features/notes/presentation/pages/notes_page.dart`; awalnya belum ada test widget khusus dialog. | **Terima dan diterapkan.** [`test/notes_page_test.dart`](../test/notes_page_test.dart) memastikan judul kosong ditolak dan tidak ada catatan yang ditambahkan. |
| 2 | Saran | Pertahankan daftar Notes dan beri umpan balik aksi saat add/update/delete gagal, alih-alih mengubah seluruh body menjadi tampilan error. | `NotesNotifier.add/updateNote/remove` memakai `AsyncValue.guard`; `NotesPage` menampilkan body error penuh pada cabang `notes.when(error: ...)`. | **Terima sebagai usulan untuk dibahas di PR.** Ubah state/error UX hanya bila pasangan menyetujui perilaku yang diharapkan dan test ditambahkan. |
| 3 | Saran (ditolak) | Memindahkan seluruh wiring konkret repository dari provider Notes karena provider mengimpor implementasi data dan pembuka SQLite. | `lib/features/notes/presentation/providers/notes_providers.dart` melakukan wiring implementasi. Widget memakai provider, bukan membuat Dio/SQLite/repository sendiri. | **Tolak untuk perubahan ini.** Provider tersebut berfungsi sebagai composition root DI yang sudah dipakai project; domain tetap tidak bergantung pada Flutter/SQLite/Dio. Memindahkan wiring hanya untuk menghilangkan import tidak membuktikan perbaikan dependency rule. |

## Verifikasi keputusan

- Temuan 1 dikonfirmasi sebagai gap test lewat struktur `test/` dan kode
  validator; validator sudah ada, jadi jangan menyatakan fitur validasi hilang.
  Widget test baru lulus di pemeriksaan Week 8.
- Temuan 2 dikonfirmasi dengan menelusuri perubahan state notifier sampai
  rendering `AsyncError`; perilaku belum diubah.
- Temuan 3 ditolak setelah memeriksa arah dependency: detail data hanya dirakit
  pada provider, sedangkan kontrak domain tidak mengimpor driver.
- Belum ada hasil review teman, komentar PR, atau bukti screenshot Week 8.

## Contoh tindak lanjut yang diusulkan

Widget test untuk temuan 1 memakai interaksi form yang sama dengan pengguna:

```dart
await tester.tap(find.widgetWithText(FloatingActionButton, 'Tambah'));
await tester.pumpAndSettle();
await tester.tap(find.widgetWithText(FilledButton, 'Tambah'));
await tester.pumpAndSettle();
expect(find.text('Judul wajib diisi'), findsOneWidget);
```

Untuk temuan 2, perubahan perlu mempertahankan data sebelumnya dan meneruskan
error ke UI agar dapat ditampilkan sebagai snackbar. Contoh pola yang perlu
diadaptasi dan diuji (bukan perubahan yang sudah diterapkan):

```dart
final previousNotes = state.value ?? const <Note>[];
try {
  // Jalankan operasi repository dan perbarui state hanya saat sukses.
} on Failure catch (failure, stackTrace) {
  state = AsyncData(previousNotes);
  Error.throwWithStackTrace(failure, stackTrace);
}
```

Sebelum demo, author tetap harus menjelaskan bukti ini tanpa mengandalkan
ringkasan AI.
