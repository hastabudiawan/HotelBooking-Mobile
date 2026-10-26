import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/error_view.dart';
import '../application/rooms_providers.dart';
import '../data/room_media.dart';
import '../data/room_models.dart';
import 'widgets/amenity_badge.dart';
import 'widgets/room_image.dart';

void _goBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/rooms');
  }
}

class RoomDetailPage extends ConsumerWidget {
  const RoomDetailPage({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(roomTypeBySlugProvider(slug));

    return room.when(
      loading: () => _PlainScaffold(
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _PlainScaffold(
        child: ErrorView(
          error: error,
          onRetry: () => ref.invalidate(roomTypeBySlugProvider(slug)),
        ),
      ),
      data: (data) => data == null
          ? _PlainScaffold(
              child: const Center(child: Text('This room could not be found.')),
            )
          : _RoomDetail(room: data),
    );
  }
}

// Kerangka sederhana (dengan tombol kembali) untuk keadaan memuat, error, dan tidak ditemukan.
class _PlainScaffold extends StatelessWidget {
  const _PlainScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goBack(context),
        ),
      ),
      body: child,
    );
  }
}

class _RoomDetail extends StatelessWidget {
  const _RoomDetail({required this.room});

  final RoomType room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final heroHeight = MediaQuery.sizeOf(context).height * 0.52;
    final amenities = getRoomMedia(room.slug).amenities;

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: heroHeight,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RoomImage(slug: room.slug, imageUrl: room.imageUrl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 8,
                    left: 16,
                    child: IconButton.filled(
                      tooltip: 'Back',
                      onPressed: () => _goBack(context),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.ink,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatRupiah(room.basePrice)} / night',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            for (final amenity in amenities)
                              Expanded(
                                child: AmenityBadge(
                                  amenity: amenity,
                                  size: 44,
                                  showLabel: true,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room Specifications',
                    style: theme.textTheme.titleLarge,
                  ),
                  if (room.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      room.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: dark ? Colors.white70 : AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 20,
                        color: dark ? Colors.white70 : AppColors.muted,
                      ),
                      const SizedBox(width: 8),
                      Text('Up to ${plural(room.capacity, 'guest')}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: FilledButton(
                onPressed: () => context.push('/book/${room.slug}'),
                child: const Text('Book room'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
