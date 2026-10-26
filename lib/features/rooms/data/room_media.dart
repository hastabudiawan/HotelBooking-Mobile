import 'package:flutter/material.dart';

enum Amenity { tv, wifi, breakfast, fireplace, console }

extension AmenityInfo on Amenity {
  String get label => switch (this) {
    Amenity.tv => 'Television',
    Amenity.wifi => 'Wifi',
    Amenity.breakfast => 'Breakfast',
    Amenity.fireplace => 'Fireplace',
    Amenity.console => 'Game console',
  };

  IconData get icon => switch (this) {
    Amenity.tv => Icons.tv_outlined,
    Amenity.wifi => Icons.wifi,
    Amenity.breakfast => Icons.free_breakfast_outlined,
    Amenity.fireplace => Icons.fireplace_outlined,
    Amenity.console => Icons.sports_esports_outlined,
  };
}

class RoomMedia {
  const RoomMedia({this.asset, required this.amenities});

  final String? asset;
  final List<Amenity> amenities;
}

const _mediaBySlug = <String, RoomMedia>{
  'standard': RoomMedia(
    asset: 'assets/images/rooms/standard.jpg',
    amenities: [Amenity.tv, Amenity.wifi, Amenity.breakfast],
  ),
  'deluxe': RoomMedia(
    asset: 'assets/images/rooms/deluxe.jpg',
    amenities: [Amenity.tv, Amenity.wifi, Amenity.breakfast, Amenity.fireplace],
  ),
  'suite': RoomMedia(
    asset: 'assets/images/rooms/suite.jpg',
    amenities: [
      Amenity.tv,
      Amenity.wifi,
      Amenity.breakfast,
      Amenity.fireplace,
      Amenity.console,
    ],
  ),
};

const _fallback = RoomMedia(amenities: [Amenity.tv, Amenity.wifi]);

RoomMedia getRoomMedia(String slug) => _mediaBySlug[slug] ?? _fallback;

// Admin mengisi imageUrl lewat panel web. Hanya http dan https yang diterima,
// dengan batas 500 karakter seperti di backend.
bool isValidImageUrl(String value) {
  final text = value.trim();
  if (text.isEmpty || text.length > 500) return false;
  final uri = Uri.tryParse(text);
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

// Urutan prioritas: imageUrl valid dari backend, lalu foto bawaan menurut slug.
// Hasilnya alamat http(s) atau path aset. Null kalau tidak ada keduanya.
String? resolveRoomImage(String slug, String? imageUrl) {
  final custom = imageUrl?.trim();
  if (custom != null && isValidImageUrl(custom)) return custom;
  return getRoomMedia(slug).asset;
}

bool isNetworkImage(String source) => source.startsWith('http');
