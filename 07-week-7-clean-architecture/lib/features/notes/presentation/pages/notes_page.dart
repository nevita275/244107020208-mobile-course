import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/failures.dart';
import '../../../../providers/app_providers.dart';
import '../../../posts/presentation/pages/posts_page.dart';
import '../../../../pages/settings_page.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

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
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            error is Failure
                                ? error.message
                                : offline
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
              Text(
                error is Failure
                    ? error.message
                    : 'Catatan tidak dapat dimuat.',
              ),
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
            itemBuilder: (context, index) {
              final note = items[index];
              return _NoteTile(
                note: note,
                onEdit: () async {
                  final draft = await showDialog<_NoteDraft>(
                    context: context,
                    builder: (_) => _NoteDialog(
                      initialTitle: note.title,
                      initialBody: note.body,
                      isEditing: true,
                    ),
                  );
                  if (draft == null || note.id == null || !context.mounted) {
                    return;
                  }
                  await ref
                      .read(notesProvider.notifier)
                      .updateNote(
                        Note(
                          id: note.id,
                          title: draft.title,
                          body: draft.body,
                          updatedAt: note.updatedAt,
                          dirty: note.dirty,
                        ),
                      );
                },
                onDelete: note.id == null
                    ? null
                    : () => ref.read(notesProvider.notifier).remove(note.id!),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final draft = await showDialog<_NoteDraft>(
            context: context,
            builder: (_) => const _NoteDialog(),
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
  const _NoteTile({
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final subtitle = <Widget>[
      if (note.body.isNotEmpty) Text(note.body),
      if (note.dirty)
        const Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            avatar: Icon(Icons.cloud_upload_outlined, size: 16),
            label: Text('Belum sinkron'),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
    ];
    return ListTile(
      onTap: onEdit,
      title: Text(note.title),
      subtitle: subtitle.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subtitle,
            ),
      trailing: IconButton(
        tooltip: 'Hapus catatan',
        onPressed: onDelete,
        icon: const Icon(Icons.delete_outline),
      ),
    );
  }
}

// Form dialog memiliki lifecycle sendiri untuk mengelola controller teks.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({
    this.initialTitle = '',
    this.initialBody = '',
    this.isEditing = false,
  });

  final String initialTitle;
  final String initialBody;
  final bool isEditing;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _bodyController = TextEditingController(text: widget.initialBody);
  }

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
      title: Text(widget.isEditing ? 'Edit catatan' : 'Catatan baru'),
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
        FilledButton(
          onPressed: _submit,
          child: Text(widget.isEditing ? 'Simpan' : 'Tambah'),
        ),
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
