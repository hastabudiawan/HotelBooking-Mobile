// GET /api/room-types dan /api/room-types/{slug}
class RoomType {
  const RoomType({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.basePrice,
    required this.capacity,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String slug;
  final String description;
  final int basePrice;
  final int capacity;
  final String? imageUrl;

  factory RoomType.fromJson(Map<String, dynamic> json) => RoomType(
    id: json['id'] as int,
    name: json['name'] as String,
    slug: json['slug'] as String,
    description: json['description'] as String? ?? '',
    basePrice: (json['basePrice'] as num).round(),
    capacity: json['capacity'] as int,
    imageUrl: json['imageUrl'] as String?,
  );
}

// GET /api/rooms/available
class AvailableRoomType {
  const AvailableRoomType({
    required this.roomTypeId,
    required this.name,
    required this.slug,
    required this.description,
    required this.pricePerNight,
    required this.capacity,
    required this.availableRooms,
    required this.nights,
    required this.totalPrice,
    this.imageUrl,
  });

  final int roomTypeId;
  final String name;
  final String slug;
  final String description;
  final int pricePerNight;
  final int capacity;
  final String? imageUrl;
  final int availableRooms;
  final int nights;
  final int totalPrice;

  factory AvailableRoomType.fromJson(Map<String, dynamic> json) =>
      AvailableRoomType(
        roomTypeId: json['roomTypeId'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String? ?? '',
        pricePerNight: (json['pricePerNight'] as num).round(),
        capacity: json['capacity'] as int,
        imageUrl: json['imageUrl'] as String?,
        availableRooms: json['availableRooms'] as int,
        nights: json['nights'] as int,
        totalPrice: (json['totalPrice'] as num).round(),
      );
}
