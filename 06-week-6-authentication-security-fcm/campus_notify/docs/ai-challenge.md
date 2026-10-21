# AI Challenge 

## 1. Ringkasan

Project ini menghubungkan Firebase Cloud Messaging (FCM) dengan notifikasi lokal, penanganan klik notifikasi, dan navigasi ke halaman pengumuman. Implementasi utama berada di `lib/messaging/push_service.dart` dan `lib/main.dart`.

Token FCM diambil melalui `FirebaseMessaging.instance.getToken()` dan dikirim menggunakan Dio ke endpoint `POST /devices`. Perubahan token ditangani melalui listener `onTokenRefresh`, yang menggunakan callback pengiriman token yang sama.

Rute dari payload notifikasi divalidasi agar hanya menerima `/` atau `/pengumuman/<angka>`. Navigasi juga ditunda ketika status autentikasi belum siap atau pengguna belum login.

**Batasan pengujian:** pemeriksaan kode tidak membuktikan bahwa notifikasi dan navigasi sudah berfungsi pada perangkat. Hasil uji foreground, background, dan terminated harus diisi setelah pengujian nyata. Endpoint `/devices` pada konfigurasi debug saat ini menggunakan respons simulasi, sehingga belum membuktikan bahwa token tersimpan di backend produksi.

## 2. Peran AI

Kode awal fitur FCM dibuat dengan bantuan AI coding assistant. Prompt dan output awal dicatat pada dokumen ini. Kode kemudian ditinjau dan disesuaikan dengan struktur project, termasuk pengelolaan callback token, payload navigasi, dan endpoint simulasi.

AI digunakan sebagai alat bantu membuat draf, bukan sebagai bukti bahwa implementasi sudah benar. Kebenaran perilaku tetap harus dibuktikan melalui pemeriksaan kode dan pengujian aplikasi.

- AI coding assistant untuk pengerjaan project: Copilot agent di VS Code.
- Output awal yang didokumentasikan: Claude (chat Anthropic).

Catatan: output awal berasal dari percakapan yang memiliki konteks project, bukan draf yang dibuat tanpa konteks sama sekali.

## 3. Prompt yang digunakan

Prompt berikut mengikuti instruksi AI Prompt Challenge dari modul.

```text
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

## 4. Output awal AI

### 4.1 Background handler (top-level, tanpa `BuildContext`)

Contoh output awal AI:

```dart
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Tidak menggunakan BuildContext, Riverpod, atau router.
  // Handler berjalan di konteks background dan tidak melakukan navigasi UI.
}
```

Pendaftaran handler dilakukan di `main()`, setelah Firebase diinisialisasi dan sebelum `runApp()`:

```dart
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
```

### 4.2 Draf awal `PushService`

Berikut inti draf awal yang dihasilkan AI. Ini merupakan catatan output awal, bukan pernyataan bahwa seluruh potongan tersebut adalah kode final project.

```dart
class PushService {
  PushService({required this.dio, required this.onNavigate});

  final Dio dio;
  final void Function(String route) onNavigate;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'pengumuman',
    'Pengumuman Kampus',
    importance: Importance.high,
  );

  Future<void> init() async {
    await _initLocal();
    await _requestPermission();
    await _registerToken();
    _listenMessages();
    await FirebaseMessaging.instance
        .subscribeToTopic('pengumuman-kampus');
    await _handleInitialMessage();
  }

  Future<void> _requestPermission() async {
    // Android 13+: periksa izin POST_NOTIFICATIONS.
    // iOS: minta izin alert, badge, dan sound.
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _registerToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _sendToken(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(_sendToken);
  }

  Future<void> _sendToken(String token) async {
    await dio.post('/devices', data: {
      'fcm_token': token,
      'platform': 'android',
    });
  }

  void _listenMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      // Tampilkan notifikasi lokal secara manual pada foreground.
      // Implementasi lengkap memerlukan NotificationDetails dan payload.
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNavigate(message.data['route'] ?? '/');
    });
  }

  Future<void> _handleInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      onNavigate(message.data['route'] ?? '/');
    }
  }

  Future<void> unsubscribeAnnouncements() {
    return FirebaseMessaging.instance
        .unsubscribeFromTopic('pengumuman-kampus');
  }
}
```

### 4.3 Catatan atas output awal

- Handler background harus berupa fungsi top-level dengan `@pragma('vm:entry-point')`.
- Listener `onTokenRefresh` harus benar-benar meneruskan token baru ke backend, bukan hanya menulis token ke log.
- Pada foreground, notifikasi lokal perlu ditampilkan secara manual jika aplikasi ingin menampilkan banner.
- Klik notifikasi lokal foreground perlu ditangani melalui callback `onDidReceiveNotificationResponse`.
- Rute dari payload adalah input eksternal sehingga harus divalidasi sebelum navigasi.
- Nilai `platform: 'android'` pada draf awal bersifat tetap. Jika aplikasi mendukung iOS, nilai platform perlu ditentukan berdasarkan platform yang sedang berjalan.
- Signature metode plugin dapat berbeda berdasarkan versi dependency yang digunakan.
- Draf awal tidak membuktikan perilaku aplikasi pada perangkat.

## 5. Perbedaan platform dan penggunaan `BuildContext`

### Android 13+

- Izin notifikasi runtime `POST_NOTIFICATIONS` perlu diperiksa dan diminta.
- Periksa deklarasi izin di `android/app/src/main/AndroidManifest.xml`.
- Untuk notifikasi lokal pada Android 8+, notification channel perlu dibuat.
- Pengujian harus dilakukan pada perangkat atau emulator dengan versi Android yang sesuai.

### iOS

- Izin alert, badge, dan sound diminta melalui `requestPermission()`.
- Inisialisasi notifikasi lokal menggunakan konfigurasi Darwin.
- Firebase harus dikonfigurasi dengan dukungan APNs yang sesuai.
- Perilaku notifikasi foreground perlu diperiksa pada perangkat iOS.

### Bagian yang tidak boleh mengakses `BuildContext`

`firebaseMessagingBackgroundHandler` merupakan fungsi top-level yang dapat berjalan pada konteks background. Fungsi ini tidak boleh bergantung pada `BuildContext`, widget, Riverpod provider yang terikat pada UI, atau router aplikasi.

`PushService` juga tidak perlu menyimpan `BuildContext`. Navigasi dilakukan melalui callback atau mekanisme router yang dikelola pada lapisan aplikasi. Callback navigasi harus dipanggil pada konteks aplikasi yang siap, bukan dari background handler.

## 6. Verifikasi (AI Verification Checklist)

| Pertanyaan | Temuan pada project | Bukti yang dicatat | Status |
|---|---|---|---|
| a. Apakah background handler top-level, memakai `@pragma('vm:entry-point')`, dan didaftarkan sebelum `runApp()`? | Pemeriksaan project mencatat handler top-level beranotasi dan pendaftaran setelah Firebase initialization sebelum `runApp()`. | `lib/messaging/push_service.dart:98-104`; `lib/main.dart:15-20` | Sesuai berdasarkan kode |
| b. Apakah `onTokenRefresh` mengirim token baru ke backend, bukan hanya mencetak log? | Listener meneruskan token baru ke callback pengiriman token dan memanggil Dio ke `/devices`. Namun, pada mode debug endpoint memberi respons simulasi dan base URL bukan backend produksi. | `lib/messaging/push_service.dart:302-335`; `lib/pages/home_page.dart:29-35`; `lib/data/api_client.dart:9-28` | Jalur kode sesuai |
| c. Apakah foreground memakai local notification manual dan hanya ada satu listener `onMessage`? | Pemeriksaan kode mencatat listener foreground memanggil fungsi yang menampilkan notifikasi lokal. Pencarian pada `lib/` sebelumnya menemukan satu listener `FirebaseMessaging.onMessage.listen`. | `lib/messaging/push_service.dart:180-190`, `220-242` | Sesuai berdasarkan kode |
| d. Apakah klik foreground, background, dan terminated menuju rute yang benar? | Kode menyediakan callback klik notifikasi lokal, `onMessageOpenedApp`, dan `getInitialMessage()`. Rute divalidasi dan navigasi ditunda ketika autentikasi belum siap. Hasil perilaku perangkat belum dicatat. | `lib/messaging/push_service.dart:83-88`, `170-218`; `lib/main.dart:36-78` | sudah sesuai |
| e1. Apakah token/secret tidak di-hardcode dan tidak di-log penuh? | Pemeriksaan sebelumnya tidak menemukan `print`, `debugPrint`, atau `log` pada `lib/`. UI debug menampilkan preview token, bukan token penuh. Nilai access/refresh mock ada pada repository autentikasi untuk simulasi dan bukan kredensial produksi. | `lib/messaging/push_service.dart:107-109`, `273-282`; `lib/pages/debug_fcm_page.dart:21-34`; `lib/data/auth_repository.dart:8-30`; `lib/data/api_client.dart:9-31` | Tidak ditemukan log token penuh; nilai mock harus tetap dibatasi untuk debug |
| e2. Bagaimana status `google-services.json`? | File tersedia secara lokal, tidak tercatat oleh `git ls-files`, dan tidak cocok dengan aturan `git check-ignore` pada pemeriksaan sebelumnya. | Hasil pemeriksaan `git ls-files` dan `git check-ignore` | Keputusan: jangan commit sebelum kebijakan repository dan konfigurasi Firebase diperiksa |
| f. Apa keputusan final dan alasannya? | Keputusan dijelaskan pada bagian 10. | Bagian 10 dokumen ini | Dijelaskan |

### Keputusan mengenai `google-services.json`

Untuk project ini, keputusan sementara adalah **tidak menambahkan `google-services.json` ke commit sebelum memastikan kebijakan repository kelompok dan kebutuhan konfigurasi tim**. File tersebut merupakan konfigurasi Firebase untuk aplikasi Android; keberadaannya tidak otomatis berarti berisi server secret, tetapi tetap harus diperiksa sebelum dibagikan.

Jika repository membutuhkan file tersebut agar anggota tim dapat menjalankan aplikasi, sepakati cara berbagi konfigurasi yang aman dengan kelompok. Jika file dikecualikan dari Git, tambahkan aturan `.gitignore` yang sesuai dan dokumentasikan cara setiap anggota memperoleh konfigurasi Firebase sendiri. Jangan menghapus atau mengubah konfigurasi lokal yang masih dibutuhkan untuk menjalankan aplikasi tanpa membuat salinan cadangan.

## 7. Perbaikan manual

Perbaikan berikut dicatat dari proses review project. Ini adalah perbaikan saat meninjau project dan tidak boleh dianggap sebagai bukti bahwa semua masalah tersebut berasal dari output awal AI.

| Temuan | Perbaikan yang diterapkan/dicatat | Bukti |
|---|---|---|
| Callback token refresh berpotensi memakai `ref` widget setelah `HomePage` dispose jika callback bergantung pada widget. | Dio diambil pada awal inisialisasi lalu digunakan oleh callback token agar listener tidak perlu memakai `ref` widget setelah listener terpasang. | `lib/pages/home_page.dart:29-35`; `lib/messaging/push_service.dart:302-319` |
| Body `POST /devices` perlu mengikuti format project. | Body request menggunakan `fcm_token` dan `platform`. Nilai platform tetap perlu dipastikan benar untuk Android dan iOS. | `lib/messaging/push_service.dart:273-278` |
| Base URL belum menunjuk backend produksi dan login menggunakan data mock. | Endpoint `/devices` memberi respons simulasi sukses hanya pada `kDebugMode`. Karena itu, keberhasilan respons simulasi tidak dianggap bukti penyimpanan token di backend nyata. | `lib/data/api_client.dart:9-28`; `lib/data/auth_repository.dart:8-30` |
| Rute dari payload dapat berasal dari input eksternal. | Rute divalidasi agar hanya menerima `/` atau `/pengumuman/<angka>`. | `lib/messaging/push_service.dart:83-88` |
| Navigasi bisa terjadi ketika status autentikasi belum siap. | Rute notifikasi ditunda sampai status autentikasi siap dan aturan login dapat diterapkan. | `lib/main.dart:51-78` |
| Banner foreground berisiko muncul ganda jika ada lebih dari satu listener atau mekanisme tampilan. | Pemeriksaan kode mencatat satu listener `onMessage` dan penggunaan notifikasi lokal manual. Pengujian perangkat tetap diperlukan untuk membuktikan banner tidak ganda. | `lib/messaging/push_service.dart:180-190`, `220-242` |

### Hasil analisis statis

`flutter analyze` dilaporkan bersih pada pemeriksaan project sebelumnya. Hasil ini menunjukkan tidak ditemukan masalah yang dilaporkan oleh analyzer pada saat pemeriksaan tersebut, tetapi bukan bukti bahwa seluruh alur FCM berhasil.

**Hasil pengujian `onTokenRefresh` di perangkat:** Belum diuji/didokumentasikan. Lengkapi setelah menjalankan pengujian pada perangkat. Karena backend saat ini disimulasikan, keberhasilan request debug hanya membuktikan jalur kode dijalankan, bukan token tersimpan pada server produksi.

## 8. Tabel hasil uji tiga app state

**Penting:** hasil di bawah ini belum diisi sebagai berhasil karena belum tersedia bukti pengujian perangkat dalam dokumentasi. Jalankan pengujian dan ganti status berdasarkan hasil aktual.

| State | Cara uji | Hasil yang diharapkan | Hasil aktual | Status | Bukti screenshot |
|---|---|---|---|---|---|
| Foreground — route `/pengumuman/3` | Jalankan aplikasi dan biarkan tetap terbuka. Kirim pesan FCM dengan `data.route=/pengumuman/3`, lalu ketuk notifikasi lokal jika tampil. | Notifikasi lokal muncul. Setelah diketuk, pengguna yang sudah login diarahkan ke `/pengumuman/3`. Jika belum login, rute ditunda sampai login berhasil. | Belum diuji | Belum diuji | ![](../screenshots/run8.png)|
| Background — route `/pengumuman/3` | Pindahkan aplikasi ke background tanpa force-stop. Kirim FCM dengan `data.route=/pengumuman/3`, lalu ketuk notifikasi sistem. | `onMessageOpenedApp` memproses pesan dan aplikasi menuju `/pengumuman/3`; jika belum login, rute ditunda sampai login berhasil. | Belum diuji | Belum diuji | ![](../screenshots/run9.png) |
| Terminated — route `/pengumuman/3` | Hentikan aplikasi, kirim FCM, lalu buka aplikasi dengan mengetuk notifikasi. Jangan menyamakan force-stop Android dengan sekadar menutup tampilan aplikasi. | `getInitialMessage()` memproses pesan yang membuka aplikasi dan aplikasi menuju `/pengumuman/3`; jika autentikasi belum siap, rute ditunda. | Belum diuji | Belum diuji | ![](../screenshots/run10.png) |
| Keterbatasan perangkat | Catat versi OS, jenis perangkat/emulator, status izin, koneksi, dan kendala pengiriman FCM. | Lingkungan dan kendala pengujian tercatat dengan jelas. | Belum dicatat | Belum diuji | - |

## 9. Lifecycle token 

1. Aplikasi meminta izin notifikasi melalui mekanisme yang sesuai dengan platform.
2. Aplikasi memanggil `FirebaseMessaging.instance.getToken()` untuk memperoleh token FCM jika tersedia.
3. Jika token tersedia, callback dari `HomePage` meneruskannya melalui `recordTokenSentToBackend()`.
4. Token dikirim menggunakan Dio ke endpoint `/devices` dengan field `fcm_token` dan `platform`.
5. Listener `onTokenRefresh` menerima token baru ketika Firebase menerbitkan perubahan token.
6. Token baru diteruskan ke callback pengiriman token yang sama, sehingga aplikasi mencoba mengirim pembaruan ke `/devices`.
7. Aplikasi juga melakukan subscribe ke topic `pengumuman-kampus` sesuai alur inisialisasi project.
8. Halaman Debug FCM menampilkan preview token, bukan keseluruhan token.

### Mengapa token perlu diperbarui?

Token FCM dapat berubah. Backend harus diperbarui dengan token terbaru agar pengiriman pesan tidak terus menggunakan token lama. Pengujian harus memastikan listener berjalan dan request pengiriman token dilakukan. Reinstall aplikasi, penghapusan data aplikasi, atau rotasi token merupakan skenario yang dapat dipertimbangkan ketika menguji perubahan token, tetapi jangan mengklaim skenario tertentu berhasil tanpa mengujinya.

Karena endpoint `/devices` pada mode debug saat ini disimulasikan, project ini belum membuktikan token baru tersimpan pada backend produksi.

## 10. Keputusan final dan alasan teknis

### 10.1 Keputusan teknis berdasarkan implementasi

- Rute notifikasi dibatasi hanya ke `/` dan `/pengumuman/<angka>`. Payload berasal dari luar aplikasi sehingga tidak boleh langsung dipercaya sebagai tujuan navigasi.
- Rute notifikasi ditahan saat status autentikasi masih loading atau pengguna belum login, lalu diproses setelah kondisi autentikasi siap.
- Untuk rute pengumuman, aplikasi membuka Beranda lalu melakukan navigasi ke halaman pengumuman agar alur stack sesuai dengan rancangan aplikasi.
- Listener foreground `onMessage` digunakan untuk menampilkan local notification manual. Pemeriksaan kode mencatat satu listener agar tidak ada beberapa handler foreground yang tanpa sengaja menampilkan banner yang sama.
- Token yang ditampilkan pada Debug FCM dibatasi menjadi preview, bukan token penuh.
- Subscribe topic `pengumuman-kampus` tersedia dalam alur inisialisasi dan kontrol debug menyediakan aksi subscribe/unsubscribe.
- Listener `onTokenRefresh` tidak dihentikan pada implementasi yang ditinjau, dan token perangkat belum dihapus dari backend ketika logout. Ini merupakan keterbatasan yang perlu dipertimbangkan jika aplikasi digunakan di luar konteks demo.
- Endpoint `/devices` masih simulasi pada mode debug. Karena itu, keberhasilan request simulasi tidak sama dengan bukti token tersimpan di backend produksi.
- Keputusan mengenai `google-services.json` adalah tidak melakukan commit sebelum kebijakan repository dan kebutuhan konfigurasi tim dikonfirmasi. Jika file dikecualikan dari Git, aturan `.gitignore` dan petunjuk konfigurasi lokal harus disediakan.

### 10.2 Alasan teknis dan pendapat saya

Saya membatasi rute notifikasi hanya ke `/` dan `/pengumuman/<angka>` karena data payload berasal dari luar aplikasi dan tidak boleh dipercaya begitu saja untuk menentukan halaman tujuan. Rute notifikasi ditahan sampai status autentikasi selesai dimuat karena router memiliki aturan redirect ke halaman login; tanpa penanganan ini, tujuan dari notifikasi dapat hilang saat pengguna belum login.

Listener foreground dibuat satu dan notifikasi ditampilkan secara lokal karena aplikasi perlu menampilkan banner ketika pesan diterima saat aplikasi aktif. Token hanya ditampilkan sebagai preview pada halaman Debug FCM agar token lengkap tidak mudah terlihat di screenshot atau log. Dio diambil sekali saat inisialisasi supaya listener `onTokenRefresh` tidak bergantung pada `ref` widget setelah `HomePage` dibuang.

Endpoint `POST /devices` masih menggunakan simulasi pada mode debug karena base URL belum menunjuk ke server produksi. Karena itu, bukti yang tersedia saat ini adalah implementasi jalur kode dan konfigurasi debug, bukan bukti data token telah tersimpan pada server nyata. File `google-services.json` tidak akan saya commit sebelum kebijakan repository dan kebutuhan konfigurasi kelompok dipastikan. Jika file perlu dibagikan agar anggota tim dapat menjalankan project, cara distribusinya harus disepakati dan tidak boleh menyertakan kredensial server atau secret.

### 10.3 Kesimpulan akhir

Implementasi sudah memiliki jalur kode untuk pengambilan token, penanganan refresh token, notifikasi foreground, penanganan klik notifikasi background/terminated, validasi rute, dan subscribe/unsubscribe topic. Pemeriksaan kode dan analyzer membantu menemukan masalah statis, tetapi belum menggantikan pengujian perilaku.

Status akhir pengujian foreground, background, terminated, dan refresh token harus ditetapkan setelah pengujian perangkat. Sampai bukti tersebut dicatat, hasil perilaku dinyatakan **belum dibuktikan**, sedangkan pengiriman ke backend produksi dinyatakan **belum diverifikasi karena endpoint masih simulasi**.
