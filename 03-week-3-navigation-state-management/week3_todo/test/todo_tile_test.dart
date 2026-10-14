import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/todo_provider.dart';
import 'package:week3_todo/widgets/todo_tile.dart';

void main() {
  testWidgets('TodoTile memanggil callback toggle dan delete', (tester) async {
    var toggled = 0, deleted = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TodoTile(
          todo: const Todo(id: 1, title: 'Uji tile'),
          onToggle: () => toggled++,
          onDelete: () => deleted++,
        ),
      ),
    ));

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.byIcon(Icons.delete));

    expect(toggled, 1);
    expect(deleted, 1);
  });
}