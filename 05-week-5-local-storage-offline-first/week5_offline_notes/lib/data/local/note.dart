// Model catatan sekaligus aturan pemetaan ke kolom SQLite.
class Note {
	const Note({
		this.id,
		required this.title,
		this.body = '',
		required this.updatedAt,
		this.dirty = false,
	});

	final int? id;
	final String title;
	final String body;
	final DateTime updatedAt;
	final bool dirty;

	// Mengubah model ke nama kolom database yang dipakai modul.
	Map<String, Object?> toMap() => {
		'id': id,
		'title': title,
		'body': body,
		'updated_at': updatedAt.toIso8601String(),
		'dirty': dirty ? 1 : 0,
	};

	// Nilai hilang atau null diberi default aman saat membaca baris database.
	factory Note.fromMap(Map<String, Object?> map) {
		return Note(
			id: (map['id'] as num?)?.toInt(),
			title: map['title'] as String? ?? '',
			body: map['body'] as String? ?? '',
			updatedAt:
					DateTime.tryParse(map['updated_at'] as String? ?? '') ??
					DateTime.fromMillisecondsSinceEpoch(0),
			dirty: ((map['dirty'] as num?)?.toInt() ?? 0) == 1,
		);
	}
}
