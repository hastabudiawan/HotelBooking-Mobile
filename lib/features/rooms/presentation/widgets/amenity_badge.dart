import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/room_media.dart';

// Lingkaran putih berisi ikon fasilitas, dengan label di bawahnya (opsional).
// Dipakai di atas foto, jadi labelnya putih.
class AmenityBadge extends StatelessWidget {
  const AmenityBadge({
    super.key,
    required this.amenity,
    this.size = 28,
    this.showLabel = false,
  });

  final Amenity amenity;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final circle = Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(amenity.icon, size: size * 0.55, color: AppColors.brand),
    );

    if (!showLabel) return circle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        const SizedBox(height: 4),
        Text(
          amenity.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
    );
  }
}
