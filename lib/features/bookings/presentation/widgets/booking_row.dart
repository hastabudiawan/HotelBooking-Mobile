import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/dates.dart';
import '../../../../core/utils/format.dart';
import '../../../rooms/application/rooms_providers.dart';
import '../../../rooms/data/room_media.dart';
import '../../../rooms/presentation/widgets/amenity_badge.dart';
import '../../../rooms/presentation/widgets/room_image.dart';
import '../../data/booking_models.dart';
import 'booking_form_widgets.dart';
import 'status_badge.dart';

class BookingRow extends ConsumerWidget {
  const BookingRow({super.key, required this.booking, required this.status});

  final Booking booking;

  // Status yang ditampilkan (Pending yang lewat batas dianggap Expired).
  final BookingStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final imageUrl = ref
        .watch(roomTypesProvider)
        .maybeWhen(
          data: (types) => types
              .where((type) => type.slug == booking.roomTypeSlug)
              .firstOrNull
              ?.imageUrl,
          orElse: () => null,
        );
    final amenities = getRoomMedia(booking.roomTypeSlug).amenities.take(3);

    return Material(
      color: surfaceColor(context),
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/bookings/${booking.id}'),
        child: SizedBox(
          height: 128,
          child: Row(
            children: [
              SizedBox(
                width: 96,
                child: RoomImage(
                  slug: booking.roomTypeSlug,
                  imageUrl: imageUrl,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.roomTypeName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatRupiah(booking.totalPrice),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      StatusBadge(status: status),
                      Row(
                        children: [
                          for (final amenity in amenities) ...[
                            AmenityBadge(amenity: amenity, size: 22),
                            const SizedBox(width: 4),
                          ],
                          const Spacer(),
                          Text(
                            formatDateRange(
                              booking.checkIn,
                              booking.checkOut,
                              currentYear: hotelToday().year,
                            ),
                            style: TextStyle(
                              fontSize: 11,
                              color: mutedColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
