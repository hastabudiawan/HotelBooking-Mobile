import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/format.dart';
import '../../data/room_media.dart';
import '../../data/room_models.dart';
import 'amenity_badge.dart';
import 'room_image.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room, this.compact = false});

  final RoomType room;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amenities = getRoomMedia(room.slug).amenities.take(3);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          RoomImage(slug: room.slug, imageUrl: room.imageUrl),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(compact ? 10 : 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (compact
                                ? theme.textTheme.titleMedium
                                : theme.textTheme.titleLarge)
                            ?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatRupiah(room.basePrice)} / night',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 12 : 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final amenity in amenities) ...[
                        AmenityBadge(amenity: amenity, size: compact ? 24 : 28),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Lapisan paling atas supaya seluruh kartu bisa diketuk.
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(onTap: () => context.push('/rooms/${room.slug}')),
            ),
          ),
        ],
      ),
    );
  }
}
