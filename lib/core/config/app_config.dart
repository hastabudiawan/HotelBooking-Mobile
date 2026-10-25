import 'package:flutter/foundation.dart';

abstract final class AppConfig {
  // Diganti saat menjalankan: flutter run --dart-define=API_URL=http://192.168.1.10:8080
  static const _override = String.fromEnvironment('API_URL');

  // Alamat API dilihat dari perangkat:
  // - Emulator Android: komputermu terlihat sebagai 10.0.2.2
  // - Simulator iOS: localhost
  // - HP asli: isi lewat --dart-define dengan alamat IP komputermu
  static String get apiUrl {
    if (_override.isNotEmpty) return _override;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static const hotelName = 'Paradise View';
  // Desain memakai "Abuja, Nigeria". Backend tidak punya data lokasi, jadi ini teks tetap.
  static const hotelLocation = 'Jakarta, Indonesia';
}
