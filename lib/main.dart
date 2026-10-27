import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/storage/prefs.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/jwt.dart';

import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final prefs = await SharedPreferences.getInstance();

  // Status login dibaca sebelum aplikasi tampil, supaya router langsung tahu.
  final tokens = TokenStorage(const FlutterSecureStorage());
  final token = await tokens.readValid();
  final initialUser = token == null ? null : userFromToken(token);
  if (token != null && initialUser == null) {
    await tokens.clear(); // Token rusak: anggap belum login.
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        initialUserProvider.overrideWithValue(initialUser),
      ],
      child: const ParadiseViewApp(),
    ),
  );
}
