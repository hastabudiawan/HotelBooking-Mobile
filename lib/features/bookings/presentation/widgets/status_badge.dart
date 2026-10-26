import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/booking_models.dart';

Color _statusColor(BookingStatus status) => switch (status) {
  BookingStatus.pending => const Color(0xFFB7791F),
  BookingStatus.confirmed => AppColors.success,
  BookingStatus.checkedIn => const Color(0xFF2B7CB3),
  BookingStatus.checkedOut => AppColors.muted,
  BookingStatus.expired => AppColors.muted,
  BookingStatus.cancelled => AppColors.danger,
  BookingStatus.noShow => AppColors.danger,
};

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
