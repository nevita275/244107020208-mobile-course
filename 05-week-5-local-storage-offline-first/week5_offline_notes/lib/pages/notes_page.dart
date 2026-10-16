import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/providers.dart';
import '../data/repositories/note_repository.dart';
import 'posts_page.dart';
import 'settings_page.dart';

// Halaman daftar catatan lokal, tetap dapat digunakan tanpa jaringan.
class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirtyCount = ref.watch(dirtyCountProvider);
    final forceOffline = ref.watch(forceOfflineProvider);
    final syncState = ref.watch(syncControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        actions: [
          if (forceOffline)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(child: Chip(label: Text('Offline'))),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: _DirtyBadge(dirtyCount: dirtyCount)),
          ),
          IconButton(
            tooltip: 'Sinkronkan',
            onPressed: syncState.isLoading
                ? null
                : () async {
                    final offline = ref.read(forceOfflineProvider);
                    try {
                      final count = await ref
                          .read(syncControllerProvider.notifier)
                          .sync();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$count catatan tersinkron')),
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            offline
                                ? 'Sedang offline, sinkronisasi ditunda'
                                : 'Sinkronisasi gagal',
                          ),
                        ),
                      );
                    }
                  },
            icon: syncState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
          IconButton(
            tooltip: 'Posts',
            icon: const Icon(Icons.article_outlined),
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const PostsPage())),
          ),
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Catatan tidak dapat dimuat.'),
              TextButton(
                onPressed: () => ref.invalidate(notesProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada catatan'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => _NoteTile(
              note: items[index],
              onDelete: items[index].id == null
                  ? null
                  : () => ref
                        .read(notesProvider.notifier)
                        .remove(items[index].id!),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final draft = await showDialog<_NoteDraft>(
            context: context,
            builder: (_) => const _AddNoteDialog(),
          );
          if (draft == null) return;
          await ref.read(notesProvider.notifier).add(draft.title, draft.body);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

// Menampilkan jumlah catatan yang belum tersinkron.
class _DirtyBadge extends StatelessWidget {
  const _DirtyBadge({required this.dirtyCount});

  final AsyncValue<int> dirtyCount;

  @override
  Widget build(BuildContext context) {
    return dirtyCount.when(
      data: (count) => Semantics(
        label: '$count catatan belum tersinkron',
        child: Badge(
          label: Text('$count'),
          child: const Icon(Icons.sync_outlined),
        ),
      ),
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stackTrace) => const Tooltip(
        message: 'Jumlah belum tersinkron tidak dapat dimuat',
        child: Icon(Icons.sync_problem_outlined),
      ),
    );
  }
}

// Baris catatan menampilkan isi ringkas dan aksi hapus.
class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.note, required this.onDelete});

  final Note note;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: note.body.isEmpty ? null : Text(note.body),
      trailing: IconButton(
        tooltip: 'Hapus catatan',
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline),
      ),
    );
  }
}

// Form dialog memiliki lifecycle sendiri untuk mengelola controller teks.
class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // Validasi mencegah tombol Tambah menyimpan judul kosong.
  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      _NoteDraft(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Catatan baru'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Judul wajib diisi'
                    : null,
              ),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Isi (opsional)'),
                minLines: 1,
                maxLines: 4,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Tambah')),
      ],
    );
  }
}

// Draft hanya membawa data tervalidasi dari dialog ke notifier.
class _NoteDraft {
  const _NoteDraft({required this.title, required this.body});

  final String title;
  final String body;
}
