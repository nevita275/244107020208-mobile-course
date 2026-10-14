class Comment {
  // Konstruktor menyediakan nilai wajib yang sudah dinormalisasi oleh fromJson.
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  // Data komentar terkait dan teks yang diterima dari JSONPlaceholder.
  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  // Membuat model dengan nilai bawaan jika field hilang atau tipenya tidak sesuai.
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: json['postId'] is num ? (json['postId'] as num).toInt() : 0,
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] is String ? json['name'] as String : '',
      email: json['email'] is String ? json['email'] as String : '',
      body: json['body'] is String ? json['body'] as String : '',
    );
  }
}
