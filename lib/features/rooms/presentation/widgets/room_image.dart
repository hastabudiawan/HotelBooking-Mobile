import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/room_media.dart';

// Gambar tipe kamar: imageUrl dari backend, lalu foto bawaan menurut slug,
// lalu kotak berwarna dengan ikon tempat tidur.
class RoomImage extends StatelessWidget {
  const RoomImage({
    super.key,
    required this.slug,
    this.imageUrl,
    this.fit = BoxFit.cover,
  });

  final String slug;
  final String? imageUrl;
  final BoxFit fit;

  Widget _placeholder(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: dark ? AppColors.darkSurface : AppColors.brandSoft,
      alignment: Alignment.center,
      child: Icon(
        Icons.bed_outlined,
        size: 40,
        color: AppColors.brand.withValues(alpha: 0.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = resolveRoomImage(slug, imageUrl);
    if (source == null) return _placeholder(context);

    if (isNetworkImage(source)) {
      return CachedNetworkImage(
        imageUrl: source,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _placeholder(context),
        errorWidget: (context, url, error) => _placeholder(context),
      );
    }

    return Image.asset(
      source,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );
  }
}
