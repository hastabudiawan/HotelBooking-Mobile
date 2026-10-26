import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/features/rooms/application/rooms_providers.dart';
import 'package:paradise_view/features/rooms/data/room_models.dart';

RoomType _room(int id, String name, String slug) => RoomType(
  id: id,
  name: name,
  slug: slug,
  description: '',
  basePrice: 100000,
  capacity: 2,
);

void main() {
  final rooms = [
    _room(1, 'Standard', 'standard'),
    _room(2, 'Deluxe', 'deluxe'),
    _room(3, 'Suite', 'suite'),
  ];

  test('tanpa kata kunci dan slug, semua kamar tampil', () {
    expect(filterRoomTypes(rooms), hasLength(3));
  });

  test('mencari nama tanpa peduli huruf besar-kecil dan spasi', () {
    final result = filterRoomTypes(rooms, query: '  DEL ');
    expect(result.map((r) => r.slug), ['deluxe']);
  });

  test('kata kunci yang tidak cocok menghasilkan daftar kosong', () {
    expect(filterRoomTypes(rooms, query: 'presidential'), isEmpty);
  });

  test('filter slug menyisakan satu tipe', () {
    final result = filterRoomTypes(rooms, slug: 'suite');
    expect(result.single.name, 'Suite');
  });

  test('slug dan kata kunci digabung', () {
    expect(filterRoomTypes(rooms, slug: 'suite', query: 'del'), isEmpty);
    expect(filterRoomTypes(rooms, slug: 'deluxe', query: 'del'), hasLength(1));
  });
}
