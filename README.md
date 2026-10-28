# Paradise View: Mobile

## Fitur

Aplikasi ini untuk **tamu**. Panel resepsionis dan admin ada di versi web.

- [x] Beranda dan daftar kamar dengan filter kategori dan pencarian
- [x] Detail kamar dan pengecekan ketersediaan berdasarkan tanggal dan jumlah tamu
- [x] Daftar dan masuk (JWT disimpan di Keychain iOS / Keystore Android)
- [x] Membuat booking dengan validasi tanggal (maksimal 30 malam) dan ringkasan harga
- [x] Batas bayar 15 menit dengan hitung mundur
- [x] Pembayaran simulasi: Transfer, QRIS, Kartu (termasuk simulasi gagal)
- [x] Daftar booking Active dan Past, detail booking, dan pembatalan
- [x] Mode terang dan gelap, tersimpan di perangkat
- [x] Penanganan error yang ramah: jaringan mati, sesi habis, dan bentrok data

## Teknologi

| Bagian | Pilihan |
|---|---|
| Framework | Flutter (Dart 3) |
| State | Riverpod (`Notifier`, `FutureProvider`) |
| Navigasi | go_router (`StatefulShellRoute`, pengalihan berdasarkan login) |
| Jaringan | Dio dengan interceptor autentikasi |
| Penyimpanan aman | flutter_secure_storage |
| Preferensi | shared_preferences |
| Tampilan | Material 3, Poppins dan Raleway (dibundel) |
| Pengujian | flutter_test (73 tes) |
| CI | GitHub Actions (analyze dan test) |

## Arsitektur

Folder per fitur. Tiap fitur memisahkan data, logika aplikasi, dan tampilan.

```
lib/
├── core/         konfigurasi, klien jaringan, penyimpanan, router, tema, widget bersama
└── features/
    ├── auth/       masuk, daftar, sesi
    ├── rooms/      beranda, daftar kamar, detail, ketersediaan
    ├── bookings/   buat, bayar, daftar, detail, batal
    └── account/    menu akun, preference
```

Aturan murni (validasi menginap, pengelompokan status booking, tanggal, format Rupiah, kedaluwarsa JWT, pengalihan login) ditulis sebagai fungsi Dart biasa dan diuji.

## Menjalankan

Butuh [Flutter SDK](https://docs.flutter.dev/get-started/install), dan simulator iOS atau emulator Android.

1. Nyalakan backend (lihat repo backend). Dengan Docker Compose, API ada di `http://localhost:8080`.
2. Dari folder ini:

```bash
flutter pub get
flutter run
```

Alamat API dipilih otomatis: simulator iOS memakai `localhost`, emulator Android memakai `10.0.2.2`. Untuk server lain (misalnya HP asli di Wi-Fi yang sama, atau API yang sudah di-deploy):

```bash
flutter run --dart-define=API_URL=http://192.168.1.10:8080
```

Akun demo: `GUEST_EMAIL` / `GUEST_PASSWORD` (atau daftar akun baru dari aplikasi).

## Tes

```bash
flutter analyze
flutter test
```

73 tes mencakup validasi, format tanggal dan uang, penanganan JWT, aturan pengalihan, penyaringan kamar, aturan booking, pengelompokan booking, dan satu tes widget.

## Build

```bash
flutter build apk --release --dart-define=API_URL=https://alamat-api-https
flutter build ios --release --no-codesign --dart-define=API_URL=https://alamat-api-https
```

Build rilis hanya bisa menghubungi API ber-**HTTPS**. APK rilis ditandatangani dengan kunci debug (cukup untuk demo, tidak untuk Play Store).

## Keputusan desain

- Layar atau data yang tidak ada di backend tidak dibuat: rating bintang, favorit, masuk dengan Apple atau Google, foto profil, dan autentikasi dua langkah.
- Mata uang Rupiah dan jam hotel WIB (UTC+7). API mengirim UTC, aplikasi mengonversinya untuk tampilan.
- Booking `Pending` yang lewat batas bayar langsung tampil sebagai Expired, tanpa menunggu job latar belakang di backend.
- Sesi yang ditolak server (401) membersihkan token dan mengarahkan ke halaman masuk.

## Terkait

- Backend: https://github.com/hastabudiawan/HotelBooking-Backend
- Web: https://github.com/hastabudiawan/HotelBooking-Frontend