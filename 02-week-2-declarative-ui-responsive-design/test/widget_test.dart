import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week2_declarative_ui_responsive_design/main.dart';

void main() {
  testWidgets('Academic Overview 1 kolom di layar sempit', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    final firstCard = tester.getTopLeft(find.byType(Card).at(0));
    final secondCard = tester.getTopLeft(find.byType(Card).at(1));
    // 1 kolom: kartu ke-2 berada di BAWAH kartu ke-1 (Y berbeda jauh)
    expect(secondCard.dy - firstCard.dy, greaterThan(30));
  });

  testWidgets('Academic Overview 2 kolom di layar lebar', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());
    await tester.pumpAndSettle();

    final firstCard = tester.getTopLeft(find.byType(Card).at(0));
    final secondCard = tester.getTopLeft(find.byType(Card).at(1));
    // 2 kolom: kartu ke-1 dan ke-2 SEJAJAR (Y hampir sama)
    expect((firstCard.dy - secondCard.dy).abs(), lessThan(5));
  });
}