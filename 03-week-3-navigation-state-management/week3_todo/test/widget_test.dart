import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/main.dart';
import 'package:week3_todo/pages/stats_page.dart';

Future<void> _addTodo(WidgetTester tester, String title) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), title);
  await tester.tap(find.text('Tambah'));
  await tester.pumpAndSettle(); // tunggu dialog selesai tertutup
}


Duration? _noRetry(int retryCount, Object error) => null;

void main() {
  testWidgets('menambah tugas baru', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Belum ada tugas'), findsOneWidget);

    await _addTodo(tester, 'Kerjakan PR minggu 3');

    expect(find.text('Kerjakan PR minggu 3'), findsOneWidget);
  });

  testWidgets('state ToDo bertahan saat pindah halaman', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(retry: _noRetry, child: MyApp()),
    );
    await _addTodo(tester, 'Belajar GoRouter');

    final nav = find.byType(NavigationBar);

    await tester.tap(find.descendant(of: nav, matching: find.text('Statistik')));
    // Jangan pumpAndSettle: StatsPage punya spinner dan delay 2 detik.
    await tester.pump(); // bangun StatsPage dulu, timer 2 detik mulai di sini
    await tester.pump(const Duration(seconds: 3)); // lalu majukan waktu
    expect(find.byType(StatsPage), findsOneWidget);

    await tester.tap(find.descendant(of: nav, matching: find.text('Tugas')));
    await tester.pumpAndSettle();
    expect(find.text('Belajar GoRouter'), findsOneWidget);
  });

  testWidgets('filter Belum selesai menyembunyikan tugas selesai',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await _addTodo(tester, 'Tugas A');

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.tap(find.text('Belum selesai'));
    await tester.pumpAndSettle();

    expect(find.text('Tugas A'), findsNothing);
    expect(find.text('Tidak ada tugas pada filter ini'), findsOneWidget);
  });
}