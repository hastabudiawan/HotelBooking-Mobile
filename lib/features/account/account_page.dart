import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/confirm_dialog.dart';
import '../auth/application/auth_controller.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    // Diambil sebelum dialog, karena widget ini bisa sudah tidak aktif sesudahnya.
    final controller = ref.read(authControllerProvider.notifier);

    final confirmed = await showPillConfirmDialog(
      context,
      message: 'Are you sure ?',
      confirmLabel: 'Logout',
      cancelLabel: 'Cancel',
    );

    if (!confirmed || !context.mounted) return;

    // Pindah ke Home dulu supaya tidak diarahkan ke Sign in dengan ?next=/account.
    context.go('/home');
    await controller.logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider);
    // Router mengalihkan ke Sign in kalau belum login. Ini hanya pengaman.
    if (user == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: dark
                    ? AppColors.darkSurface
                    : AppColors.brandSoft,
                child: Text(
                  user.initials,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: dark ? Colors.white : AppColors.brand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: dark ? Colors.white60 : AppColors.muted,
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: TextButton(
                onPressed: () => _confirmLogout(context, ref),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
