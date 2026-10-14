import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_derived_providers.dart';
import '../providers/todo_provider.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  Future<void> _addTodo(BuildContext context, WidgetRef ref) async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => const AddTodoDialog(),
    );
    if (title != null && title.isNotEmpty) {
      ref.read(todoListProvider.notifier).add(title);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo Riverpod')),
      body: const Column(
        children: [
          _FilterBar(),
          Expanded(child: _TodoList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addTodo(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(todoFilterProvider);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SegmentedButton<TodoFilter>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(value: TodoFilter.all, label: Text('Semua')),
          ButtonSegment(value: TodoFilter.active, label: Text('Belum selesai')),
          ButtonSegment(value: TodoFilter.completed, label: Text('Selesai')),
        ],
        selected: {filter},
        onSelectionChanged: (s) =>
            ref.read(todoFilterProvider.notifier).set(s.first),
      ),
    );
  }
}

class _TodoList extends ConsumerWidget {
  const _TodoList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(todoListProvider);
    final visible = ref.watch(filteredTodosProvider);

    if (all.isEmpty) {
      return const Center(child: Text('Belum ada tugas'));
    }
    if (visible.isEmpty) {
      return const Center(child: Text('Tidak ada tugas pada filter ini'));
    }

    final notifier = ref.read(todoListProvider.notifier);
    return ListView.builder(
      itemCount: visible.length,
      itemBuilder: (context, i) {
        final todo = visible[i];
        return TodoTile(
          key: ValueKey(todo.id),
          todo: todo,
          onToggle: () => notifier.toggle(todo.id),
          onDelete: () => notifier.remove(todo.id),
        );
      },
    );
  }
}