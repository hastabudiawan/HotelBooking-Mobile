import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_mode_provider.dart';
import '../../core/widgets/back_scaffold.dart';

class PreferencePage extends ConsumerWidget {
  const PreferencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return BackScaffold(
      title: 'Preference',
      fallbackLocation: '/account',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark mode'),
            subtitle: const Text('Use a dark theme across the app'),
            secondary: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            ),
            value: isDark,
            onChanged: (value) {
              if (value != isDark) {
                ref.read(themeModeProvider.notifier).toggle();
              }
            },
          ),
        ],
      ),
    );
  }
}
