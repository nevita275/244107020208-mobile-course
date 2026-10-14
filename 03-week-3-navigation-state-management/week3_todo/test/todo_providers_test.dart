import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/todo_derived_providers.dart';
import 'package:week3_todo/providers/todo_provider.dart';

void main() {
  test('filteredTodosProvider mengikuti filter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(todoListProvider.notifier)
      ..add('A')
      ..add('B')
      ..toggle(0); // A selesai

    final filter = container.read(todoFilterProvider.notifier);

    filter.set(TodoFilter.active);
    expect(container.read(filteredTodosProvider).map((t) => t.title), ['B']);

    filter.set(TodoFilter.completed);
    expect(container.read(filteredTodosProvider).map((t) => t.title), ['A']);

    filter.set(TodoFilter.all);
    expect(container.read(filteredTodosProvider).length, 2);
  });
}