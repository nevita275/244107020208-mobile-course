import 'package:flutter_riverpod/flutter_riverpod.dart';

class Todo {
  const Todo({required this.id, required this.title, this.done = false});
  final int id;
  final String title;
  final bool done;

  Todo copyWith({String? title, bool? done}) =>
      Todo(id: id, title: title ?? this.title, done: done ?? this.done);
}

class TodoListNotifier extends Notifier<List<Todo>> {
  int _nextId = 0;

  @override
  List<Todo> build() => const [];

  void add(String title) =>
      state = [...state, Todo(id: _nextId++, title: title)];

  void toggle(int id) => state = [
        for (final t in state)
          if (t.id == id) t.copyWith(done: !t.done) else t,
      ];

  void remove(int id) => state = state.where((t) => t.id != id).toList();
}

final todoListProvider =
    NotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);