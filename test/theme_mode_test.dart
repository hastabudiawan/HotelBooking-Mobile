import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/core/storage/prefs.dart';
import 'package:paradise_view/core/theme/theme_mode_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> makeContainer(Map<String, Object> initial) async {
  SharedPreferences.setMockInitialValues(initial);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('tema bawaan adalah terang', () async {
    final container = await makeContainer({});
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('toggle mengubah ke gelap dan menyimpannya', () async {
    final container = await makeContainer({});
    await container.read(themeModeProvider.notifier).toggle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    final prefs = container.read(sharedPrefsProvider);
    expect(prefs.getString('theme_mode'), 'dark');
  });

  test('pilihan gelap yang tersimpan dibaca saat mulai', () async {
    final container = await makeContainer({'theme_mode': 'dark'});
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  test('toggle dua kali kembali ke terang', () async {
    final container = await makeContainer({'theme_mode': 'dark'});
    await container.read(themeModeProvider.notifier).toggle();

    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
