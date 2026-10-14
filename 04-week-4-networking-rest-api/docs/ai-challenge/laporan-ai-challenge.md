## 1. Prompt yang digunakan

### Prompt modul

Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.

### Konteks proyek

- Gunakan createDio() dan dioProvider yang sudah ada; jangan membuat instance Dio baru.
- File baru: lib/data/models/comment.dart, lib/data/repositories/comment_repository.dart, lib/data/comment_providers.dart (provider + fungsi pesan error), test/comment_test.dart.
- Gaya Riverpod 3: AsyncNotifier dengan parameter lewat constructor dan AsyncNotifierProvider.family. Jangan pakai FamilyAsyncNotifier. Nonaktifkan retry otomatis dengan retry: (retryCount, error) => null.
- Timeout 10 detik berupa satu konstanta bernama di repository.
- Fungsi pesan error memetakan semua DioExceptionType (timeout, connectionError, badResponse 404 dan 500, tipe lain) ke Bahasa Indonesia, tanpa menampilkan exception mentah.
- Semua komentar dan pesan dalam Bahasa Indonesia. Tidak perlu UI, dan jangan ubah main.dart.

## 2. Output awal AI

Salinan output awal tersedia di folder [02-output-awal/](./02-output-awal/): [comment.dart](./02-output-awal/comment.dart), [comment_repository.dart](./02-output-awal/comment_repository.dart), [comment_providers.dart](./02-output-awal/comment_providers.dart), dan [comment_test.dart](./02-output-awal/comment_test.dart).

## 3. Verifikasi dan perbaikan

Catatan: DRAF awal oleh Copilot, belum saya verifikasi.

- [ ] Apakah UI memanggil Dio langsung atau lewat repository?
  Temuan saya: Belum dapat dipastikan untuk UI Comment karena tidak ada UI Comment pada file yang diperiksa. Jalur provider yang ada memakai repository: `week4_api/lib/data/comment_providers.dart:22` berisi `ref.watch(commentRepositoryProvider).fetchComments(postId)`, lalu `week4_api/lib/data/repositories/comment_repository.dart:16` menjalankan `_dio.get<List>(...)`. [PERLU DIVERIFIKASI SAYA] untuk UI.
- [x] Apakah fromJson aman null, atau masih memakai cast langsung yang bisa crash?
  Temuan saya: Aman terhadap field hilang, `null`, dan tipe yang tidak cocok karena setiap nilai diperiksa sebelum cast dan diberi fallback. Bukti: `week4_api/lib/data/models/comment.dart:21-25`, misalnya `json['postId'] is num ? ... : 0` dan `json['name'] is String ? ... : ''`.
- [x] Apakah semua tipe DioExceptionType dipetakan ke pesan pengguna?
  Temuan saya: Switch menangani timeout, connectionError, badResponse, cancel, badCertificate, transformTimeout, dan unknown, tanpa meneruskan pesan exception mentah. Bukti: `week4_api/lib/data/comment_providers.dart:39-58`; 404 dan 500 memiliki pesan khusus pada baris 49 dan 52, sedangkan status badResponse lain memakai pesan umum pada baris 55.
- [ ] Apakah baseUrl dan timeout terpusat di satu client, bukan tersebar di tiap method?
  Temuan saya: Belum sepenuhnya. `baseUrl`, `connectTimeout`, dan `receiveTimeout` ada pada client di `week4_api/lib/data/api_client.dart:6-8`. Namun timeout komentar juga ditentukan sebagai `requestTimeout` di `week4_api/lib/data/repositories/comment_repository.dart:7`, lalu diterapkan melalui `Options` di dalam method pada baris 20-22. Jadi pengaturan timeout terbagi antara client dan repository.
- [x] Apakah test benar-benar menguji field yang hilang, atau hanya happy path?
  Temuan saya: Test awal menguji field yang hilang (`docs/ai-challenge/02-output-awal/comment_test.dart:6-14`). Test saat ini mempertahankan test itu dan juga menguji happy path, field sebagian hilang, `null` eksplisit, dan tipe yang salah (`week4_api/test/comment_test.dart:17-74`).
- [ ] Apakah flutter analyze dan flutter test lolos tanpa warning?
  Temuan saya: Screenshot `screenshots/analyzeai.png` menampilkan `No issues found!`, dan `screenshots/testai.png` menampilkan `+7: All tests passed!`. Namun screenshot test hanya memperlihatkan ringkasan akhir, sehingga ketiadaan warning sepanjang output tidak dapat dipastikan dari bukti gambar saja. [PERLU DIVERIFIKASI SAYA]

### Edge case tambahan buatan saya

Empat test yang tidak ada pada arsip `docs/ai-challenge/02-output-awal/comment_test.dart` ditambahkan di `week4_api/test/comment_test.dart`: happy path (baris 17-31), sebagian field hilang (baris 34-45), `null` eksplisit (baris 48-59), dan tipe data salah (baris 62-73). Arsip awal hanya memiliki satu test untuk semua field hilang (`02-output-awal/comment_test.dart:6-14`).

### Perbaikan yang saya lakukan

Perbandingan arsip dengan kode sekarang menunjukkan `comment.dart`, `comment_repository.dart`, dan `comment_providers.dart` identik; hanya `comment_test.dart` berbeda, dengan empat test edge case tambahan (`week4_api/test/comment_test.dart:17-74`). Pada `week4_api/test/widget_test.dart`, repository palsu dibuat di baris 9-22 dan dipasang melalui override provider pada baris 37-39 serta 57-59, sehingga test tidak mengirim HTTP sungguhan; komentar baris 9 menyebut HTTP diblokir oleh test harness Flutter. Ekspektasi disesuaikan ke judul `Posts Paged` dan post palsu pada baris 47-48. Test error koneksi dan pesan ramahnya ada pada baris 51-76.

## 4. Hasil testing

### Hasil testing awal (sebelum perbaikan saya)

#### `flutter analyze`

```text
Analyzing week4_api...                                          
No issues found! (ran in 8.5s)
```

#### `flutter test`

```text
00:00 +0: loading C:/Matkul MOBILE/244107020208-mobile-course/04-week-4-networking-rest-api/week4_api/test/comment_test.dart
00:00 +0: C:/Matkul MOBILE/244107020208-mobile-course/04-week-4-networking-rest-api/week4_api/test/comment_test.dart: fromJson memberi nilai bawaan saat semua field hilang
00:00 +1: C:/Matkul MOBILE/244107020208-mobile-course/04-week-4-networking-rest-api/week4_api/test/widget_test.dart: Menampilkan halaman Posts API yang kosong
*** Request ***
uri: https://jsonplaceholder.typicode.com/posts?_page=1&_limit=10
method: GET
responseType: ResponseType.json
followRedirects: true
persistentConnection: true
connectTimeout: 0:00:10.000000
sendTimeout: null
receiveTimeout: 0:00:10.000000
transformTimeout: null
receiveDataWhenStatusError: true
extra: {}
headers:
 Accept: application/json
data:
null

*** Request ***
uri: https://jsonplaceholder.typicode.com/posts?_page=1&_limit=10
method: GET
responseType: ResponseType.json
followRedirects: true
persistentConnection: true
connectTimeout: 0:00:10.000000
sendTimeout: null
receiveTimeout: 0:00:10.000000
transformTimeout: null
receiveDataWhenStatusError: true
extra: {}
headers:
 Accept: application/json
data:
null

*** DioException ***:
uri: https://jsonplaceholder.typicode.com/posts?_page=1&_limit=10
DioException [bad response]: This exception was thrown because the response has a status code of 400 and RequestOptions.validateStatus was configured to throw for this status code.
The status code of 400 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
In order to resolve this exception you typically have either to verify and fix your request code or to fix the server code.

*** Response ***
uri: https://jsonplaceholder.typicode.com/posts?_page=1&_limit=10
statusCode: 400
statusMessage: 
headers:


*** DioException ***:
uri: https://jsonplaceholder.typicode.com/posts?_page=1&_limit=10
DioException [bad response]: This exception was thrown because the response has a status code of 400 and RequestOptions.validateStatus was configured to throw for this status code.
The status code of 400 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
Read more about status codes at https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
In order to resolve this exception you typically have either to verify and fix your request code or to fix the server code.

*** Response ***
uri: https://jsonplaceholder.typicode.com/posts?_page=1&_limit=10
statusCode: 400
statusMessage: 
headers:


══╡ EXCEPTION CAUGHT BY FLUTTER TEST FRAMEWORK ╞════════════════════════════════════════════════════
The following TestFailure was thrown running a test:
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "Posts API": []>
   Which: means none were found

When the exception was thrown, this was the stack:
#4      main.<anonymous closure> (file:///C:/Matkul%20MOBILE/244107020208-mobile-course/04-week-4-networking-rest-api/week4_api/test/widget_test.dart:29:5)
<asynchronous suspension>
#5      testWidgets.<anonymous closure>.<anonymous closure> (package:flutter_test/src/widget_tester.dart:192:15)
<asynchronous suspension>
#6      TestWidgetsFlutterBinding._runTestBody (package:flutter_test/src/binding.dart:1953:5)
<asynchronous suspension>
<asynchronous suspension>
(elided one frame from package:stack_trace)

This was caught by the test expectation on the following line:
  file:///C:/Matkul%20MOBILE/244107020208-mobile-course/04-week-4-networking-rest-api/week4_api/test/widget_test.dart line 29
The test description was:
  Menampilkan halaman Posts API yang kosong
════════════════════════════════════════════════════════════════════════════════════════════════════
00:01 +1 -1: C:/Matkul MOBILE/244107020208-mobile-course/04-week-4-networking-rest-api/week4_api/test/widget_test.dart: Menampilkan halaman Posts API yang kosong [E]
  Test failed. See exception logs above.
  The test description was: Menampilkan halaman Posts API yang kosong
  
Warning: At least one test in this suite creates an HttpClient. When running a test suite that uses
TestWidgetsFlutterBinding, all HTTP requests will return status code 400, and no network request
will actually be made. Any test expecting a real network connection and status code will fail.
To test code that needs an HttpClient, provide your own HttpClient implementation to the code under
test, so that your code can consistently provide a testable response to the code under test.
00:02 +1 -1: Some tests failed.

Failing tests:
  C:/Matkul MOBILE/244107020208-mobile-course/04-week-4-networking-rest-api/week4_api/test/widget_test.dart: Menampilkan halaman Posts API yang kosong
```

#### Ringkasan

- `flutter analyze`: lolos.
- `flutter test`: gagal; `comment_test.dart` lolos, tetapi tes widget gagal dan runner menampilkan warning `HttpClient`.

### Hasil testing setelah perbaikan
#### `flutter analyze`
![](../../screenshots/analyzeai.png)
#### `flutter test`
![](../../screenshots/testai.png)

#### Ringkasan

#### `flutter analyze`
![](../../screenshots/analyzeai.png)
#### `flutter test`
![](../../screenshots/testai.png)