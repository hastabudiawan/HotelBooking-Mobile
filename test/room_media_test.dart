import 'package:flutter_test/flutter_test.dart';
import 'package:paradise_view/features/rooms/data/room_media.dart';

void main() {
  test('isValidImageUrl hanya menerima http dan https dengan host', () {
    expect(isValidImageUrl('https://contoh.com/kamar.jpg'), isTrue);
    expect(isValidImageUrl('http://contoh.com/kamar.jpg'), isTrue);
    expect(isValidImageUrl('ftp://contoh.com/kamar.jpg'), isFalse);
    expect(isValidImageUrl('javascript:alert(1)'), isFalse);
    expect(isValidImageUrl('bukan alamat'), isFalse);
    expect(isValidImageUrl(''), isFalse);
    expect(isValidImageUrl('https://contoh.com/${'a' * 500}'), isFalse);
  });

  test('resolveRoomImage mengutamakan imageUrl yang valid', () {
    expect(
      resolveRoomImage('deluxe', 'https://contoh.com/a.jpg'),
      'https://contoh.com/a.jpg',
    );
  });

  test('imageUrl tidak valid atau kosong memakai foto bawaan menurut slug', () {
    expect(
      resolveRoomImage('deluxe', 'bukan alamat'),
      'assets/images/rooms/deluxe.jpg',
    );
    expect(resolveRoomImage('suite', null), 'assets/images/rooms/suite.jpg');
  });

  test('slug tidak dikenal tanpa imageUrl tidak punya gambar', () {
    expect(resolveRoomImage('presidential', null), isNull);
  });

  test('getRoomMedia memberi fasilitas dasar untuk slug tidak dikenal', () {
    expect(getRoomMedia('presidential').amenities, [Amenity.tv, Amenity.wifi]);
    expect(getRoomMedia('suite').amenities, contains(Amenity.console));
  });

  test('isNetworkImage membedakan alamat dan path aset', () {
    expect(isNetworkImage('https://contoh.com/a.jpg'), isTrue);
    expect(isNetworkImage('assets/images/rooms/suite.jpg'), isFalse);
  });
}
