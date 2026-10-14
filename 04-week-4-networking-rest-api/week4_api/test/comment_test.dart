import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  // Field yang tidak tersedia harus menghasilkan nilai bawaan, bukan kegagalan.
  test('fromJson memberi nilai bawaan saat semua field hilang', () {
    final comment = Comment.fromJson(const {});

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  // Menguji semua field terisi dan terbaca sesuai nilainya.
  test('fromJson membaca semua field yang terisi', () {
    final comment = Comment.fromJson({
      'postId': 5,
      'id': 12,
      'name': 'Nama komentar',
      'email': 'komentar@example.com',
      'body': 'Isi komentar',
    });

    expect(comment.postId, 5);
    expect(comment.id, 12);
    expect(comment.name, 'Nama komentar');
    expect(comment.email, 'komentar@example.com');
    expect(comment.body, 'Isi komentar');
  });

  // Menguji bahwa field yang hilang memakai nilai bawaan masing-masing.
  test('fromJson memberi nilai bawaan untuk field yang sebagian hilang', () {
    final comment = Comment.fromJson({
      'id': 12,
      'name': 'Nama komentar',
    });

    expect(comment.postId, 0);
    expect(comment.id, 12);
    expect(comment.name, 'Nama komentar');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  // Menguji bahwa null eksplisit untuk field teks menghasilkan string kosong.
  test('fromJson memberi string kosong untuk field null eksplisit', () {
    final comment = Comment.fromJson({
      'name': null,
      'email': null,
    });

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });

  // Menguji bahwa tipe data yang salah ditolak dan diganti nilai bawaan.
  test('fromJson memberi nilai bawaan untuk tipe data yang salah', () {
    final comment = Comment.fromJson({
      'postId': '5',
      'name': 42,
    });

    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
