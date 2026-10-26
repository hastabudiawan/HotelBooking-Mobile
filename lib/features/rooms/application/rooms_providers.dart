import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/room_models.dart';
import '../data/rooms_repository.dart';

// Daftar tipe kamar, dipakai bersama oleh Home dan Rooms.
final roomTypesProvider = FutureProvider<List<RoomType>>(
  (ref) => ref.watch(roomsRepositoryProvider).getRoomTypes(),
);

// Satu tipe kamar menurut slug. Null kalau slug tidak ada.
final roomTypeBySlugProvider = FutureProvider.autoDispose
    .family<RoomType?, String>(
      (ref, slug) => ref.watch(roomsRepositoryProvider).getRoomTypeBySlug(slug),
    );

// Teks pencarian, dibagi antara kolom di Home dan kolom di Rooms.
class RoomSearchController extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
}

final roomSearchProvider = NotifierProvider<RoomSearchController, String>(
  RoomSearchController.new,
);

// Mencari berdasarkan nama (tanpa peduli huruf besar-kecil), dan opsional
// hanya satu tipe menurut slug.
List<RoomType> filterRoomTypes(
  List<RoomType> rooms, {
  String query = '',
  String? slug,
}) {
  final needle = query.trim().toLowerCase();
  return rooms.where((room) {
    if (slug != null && room.slug != slug) return false;
    if (needle.isEmpty) return true;
    return room.name.toLowerCase().contains(needle);
  }).toList();
}
