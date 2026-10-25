import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/providers.dart';
import '../../../core/utils/dates.dart';
import 'room_models.dart';

class RoomsRepository {
  RoomsRepository(this._api);

  final ApiClient _api;

  Future<List<RoomType>> getRoomTypes() {
    return _api.get(
      '/api/room-types',
      parse: (json) => (json as List)
          .map((e) => RoomType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Null kalau slug tidak ada (backend menjawab 404).
  Future<RoomType?> getRoomTypeBySlug(String slug) async {
    try {
      return await _api.get(
        '/api/room-types/${Uri.encodeComponent(slug)}',
        parse: (json) => RoomType.fromJson(json as Map<String, dynamic>),
      );
    } on ApiException catch (error) {
      if (error.isNotFound) return null;
      rethrow;
    }
  }

  Future<List<AvailableRoomType>> searchAvailable({
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) {
    return _api.get(
      '/api/rooms/available',
      query: {
        'checkIn': toApiDate(checkIn),
        'checkOut': toApiDate(checkOut),
        'guests': guests,
      },
      parse: (json) => (json as List)
          .map((e) => AvailableRoomType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

final roomsRepositoryProvider = Provider<RoomsRepository>(
  (ref) => RoomsRepository(ref.watch(apiClientProvider)),
);
