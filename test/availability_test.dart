import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/core/network/api_exception.dart';
import 'package:paradise_view/features/bookings/application/availability.dart';
import 'package:paradise_view/features/rooms/data/room_models.dart';
import 'package:paradise_view/features/rooms/data/rooms_repository.dart';

class FakeRoomsRepository implements RoomsRepository {
  FakeRoomsRepository({this.results = const [], this.error});

  final List<AvailableRoomType> results;
  final ApiException? error;
  int searchCalls = 0;

  @override
  Future<List<RoomType>> getRoomTypes() => throw UnimplementedError();

  @override
  Future<RoomType?> getRoomTypeBySlug(String slug) =>
      throw UnimplementedError();

  @override
  Future<List<AvailableRoomType>> searchAvailable({
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    searchCalls++;
    if (error != null) throw error!;
    return results;
  }
}

AvailableRoomType _item(String slug) => AvailableRoomType(
  roomTypeId: 1,
  name: 'Deluxe',
  slug: slug,
  description: '',
  pricePerNight: 750000,
  capacity: 3,
  availableRooms: 2,
  nights: 2,
  totalPrice: 1500000,
);

void main() {
  final today = DateTime(2026, 11, 10);

  AvailabilityQuery query({DateTime? checkIn, DateTime? checkOut}) => (
    slug: 'deluxe',
    checkIn: checkIn ?? DateTime(2026, 11, 11),
    checkOut: checkOut ?? DateTime(2026, 11, 13),
    guests: 2,
  );

  test('tanggal tidak valid ditolak tanpa memanggil backend', () async {
    final repository = FakeRoomsRepository();
    final result = await checkRoomAvailability(
      repository,
      query(checkIn: DateTime(2026, 11, 1)),
      today: today,
    );

    expect(result, isA<StayInvalid>());
    expect(repository.searchCalls, 0);
  });

  test('tipe kamar ada di hasil: tersedia', () async {
    final result = await checkRoomAvailability(
      FakeRoomsRepository(results: [_item('standard'), _item('deluxe')]),
      query(),
      today: today,
    );

    expect(result, isA<RoomAvailable>());
    expect((result as RoomAvailable).item.slug, 'deluxe');
  });

  test('tipe kamar tidak ada di hasil: tidak tersedia', () async {
    final result = await checkRoomAvailability(
      FakeRoomsRepository(results: [_item('standard')]),
      query(),
      today: today,
    );

    expect(result, isA<RoomUnavailable>());
  });

  test('400 dari backend menjadi StayInvalid dengan pesannya', () async {
    final result = await checkRoomAvailability(
      FakeRoomsRepository(
        error: const ApiException(
          'Maksimal menginap 30 malam.',
          statusCode: 400,
        ),
      ),
      query(),
      today: today,
    );

    expect(result, isA<StayInvalid>());
    expect((result as StayInvalid).message, 'Maksimal menginap 30 malam.');
  });

  test('error lain (misalnya server mati) dilempar ke atas', () async {
    await expectLater(
      checkRoomAvailability(
        FakeRoomsRepository(error: const ApiException(networkErrorMessage)),
        query(),
        today: today,
      ),
      throwsA(isA<ApiException>()),
    );
  });
}
