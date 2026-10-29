# Checklist Mid Project Review

## Audit branch dan commit

Audit dilakukan pada riwayat `origin/main` saat menyiapkan branch fitur. Tiga
pesan berikut adalah contoh nyata yang dapat diperjelas; tabel ini hanya
simulasi pesan yang lebih deskriptif dan **tidak mengubah riwayat Git**.

| Pesan lama | Usulan pesan yang lebih jelas | Alasan |
|---|---|---|
| `menambahkan di readme` | `docs(readme): tambahkan navigasi tugas mingguan` | Menjelaskan tipe perubahan dan lokasi dokumentasi. |
| `menambahkan di readme` | `docs(readme): perbarui navigasi tugas mingguan` | Membuat perubahan kedua dapat dibedakan dari commit pertama. |
| `praktikum week 7` | `docs(week7): dokumentasikan hasil praktikum clean architecture` | Menyebut cakupan dan hasil yang dicatat. |

Jangan amend/rewrite commit lama hanya untuk latihan ini. Branch panjang umur
dan commit langsung ke `main` perlu dicek kembali sebelum mengirim PR.

## Pemeriksaan sebelum PR

- [x] Branch `develop` dibuat dari `origin/main` dan sudah dipush; isinya
  saat ini Week 1–7.
- [x] Branch kerja `feature/08-week-8-mid-project-review` dibuat dari `develop`.
- [x] Perubahan Week 8 sudah di-stage pada branch fitur lokal.
- [x] Satu project Week 7 dipertahankan sebagai fokus review Week 8.
- [ ] Commit dan push branch fitur agar branch remote memuat Week 1–8.
- [ ] Buat PR fitur ke `develop`; setelah review dan approve, merge agar
  `develop` memuat Week 1–8.
- [ ] Untuk Week 9–16, mulai tiap branch fitur dari `develop` terbaru dan
  merge PR yang sudah disetujui agar `develop` tetap kumulatif.
- [x] `flutter analyze`, `dart format`, dan `flutter test` hijau; hasil ada di
  [`verification.md`](verification.md).
- [ ] Buat issue dan PR kecil ke `develop`; isi template dan screenshot.
- [ ] Pasangan melakukan review dengan checkout dan menjalankan aplikasi/test.
- [ ] Catat minimal 2 temuan kebenaran, 1 arsitektur, 1 test, dan 1
  keterbacaan; jangan mengarang komentar reviewer.
- [ ] Tindak lanjuti komentar, minta re-review, dan tunggu **Approve**.
- [ ] Merge via review dan verifikasi issue tertutup; hapus branch remote setelah
  merge.
- [ ] Perbarui status README dengan tautan issue/PR dan hasil review yang nyata.

## Catatan peer review

| Kategori | Temuan/tautan komentar | Tindak lanjut | Status |
|---|---|---|---|
| Kebenaran 1 | Menunggu reviewer | Menunggu author | Belum |
| Kebenaran 2 | Menunggu reviewer | Menunggu author | Belum |
| Arsitektur | Menunggu reviewer | Menunggu author | Belum |
| Test | Menunggu reviewer | Menunggu author | Belum |
| Keterbacaan | Menunggu reviewer | Menunggu author | Belum |

Keputusan review akhir: **belum ada**. Review oleh teman dan merge tidak dapat
disimulasikan oleh AI.
