import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/application/auth_controller.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_client.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(const FlutterSecureStorage()),
);

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(
    baseUrl: AppConfig.apiUrl,
    tokens: ref.watch(tokenStorageProvider),
    // Dibaca saat dipanggil (bukan saat dibuat), jadi tidak ada lingkaran antar provider.
    onUnauthorized: () =>
        ref.read(authControllerProvider.notifier).sessionExpired(),
  ),
);
