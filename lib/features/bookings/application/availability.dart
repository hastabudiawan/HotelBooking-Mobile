import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/dates.dart';
import '../../rooms/data/room_models.dart';
import '../../rooms/data/rooms_repository.dart';
import '../domain/stay_rules.dart';

sealed class RoomAvailability {
  const RoomAvailability();
}

class RoomAvailable extends RoomAvailability {
  const RoomAvailable(this.item);

  final AvailableRoomType item;
}

class RoomUnavailable extends RoomAvailability {
  const RoomUnavailable();
}

// Tanggal ditolak (aturan di aplikasi atau 400 dari backend).
class StayInvalid extends RoomAvailability {
  const StayInvalid(this.message);

  final String message;
}

typedef AvailabilityQuery = ({
  String slug,
  DateTime checkIn,
  DateTime checkOut,
  int guests,
});

Future<RoomAvailability> checkRoomAvailability(
  RoomsRepository repository,
  AvailabilityQuery query, {
  required DateTime today,
}) async {
  final problem = validateStay(query.checkIn, query.checkOut, today);
  if (problem != null) return StayInvalid(problem);

  try {
    final results = await repository.searchAvailable(
      checkIn: query.checkIn,
      checkOut: query.checkOut,
      guests: query.guests,
    );
    final item = results.where((r) => r.slug == query.slug).firstOrNull;
    return item == null ? const RoomUnavailable() : RoomAvailable(item);
  } on ApiException catch (error) {
    if (error.statusCode == 400) return StayInvalid(error.message);
    rethrow;
  }
}

// Setiap kombinasi tanggal dan tamu adalah satu "pertanyaan" yang di-cache
// selama layar terbuka.
final availabilityProvider = FutureProvider.autoDispose
    .family<RoomAvailability, AvailabilityQuery>(
      (ref, query) => checkRoomAvailability(
        ref.watch(roomsRepositoryProvider),
        query,
        today: hotelToday(),
      ),
    );
