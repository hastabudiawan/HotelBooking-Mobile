import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

Future<bool> showPillConfirmDialog(
  BuildContext context, {
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(dialogContext).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      minimumSize: const Size.fromHeight(44),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size.fromHeight(44),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}
