import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../config/app_config.dart';
import '../theme/app_colors.dart';
import '../theme/theme_mode_provider.dart';

// Baris atas Home dan Rooms: lokasi, tombol tema (hanya Home), dan avatar.
class AppHeader extends ConsumerWidget {
  const AppHeader({super.key, this.showThemeToggle = false});

  final bool showThemeToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: AppColors.danger, size: 18),
          const SizedBox(width: 4),
          Text(
            AppConfig.hotelLocation,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (showThemeToggle)
            IconButton(
              tooltip: 'Toggle theme',
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              ),
              onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => context.go('/account'),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.brandSoft,
              child: user == null
                  ? Icon(
                      Icons.person_outline,
                      size: 20,
                      color: isDark ? Colors.white : AppColors.brand,
                    )
                  : Text(
                      user.initials,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.brand,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
