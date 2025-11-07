class Property {
  final String id;
  final String title;
  final String description;
  final String type; // apartment, house, villa, etc.
  final String transactionType; // sale, rent
  final double price;
  final double surface; // m²
  final int rooms;
  final int bedrooms;
  final int bathrooms;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final List<String> images;
  final String ownerId;
  final String ownerName;
  final String? ownerPhone;
  final bool isFavorite;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.transactionType,
    required this.price,
    required this.surface,
    required this.rooms,
    required this.bedrooms,
    required this.bathrooms,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhone,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      type: json['type'],
      transactionType: json['transaction_type'],
      price: double.parse(json['price'].toString()),
      surface: double.parse(json['surface'].toString()),
      rooms: json['rooms'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      address: json['address'],
      city: json['city'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      images: List<String>.from(json['images'] ?? []),
      ownerId: json['owner_id'].toString(),
      ownerName: json['owner_name'],
      ownerPhone: json['owner_phone'],
      isFavorite: json['is_favorite'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'transaction_type': transactionType,
      'price': price,
      'surface': surface,
      'rooms': rooms,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'owner_phone': ownerPhone,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Property copyWith({bool? isFavorite}) {
    return Property(
      id: id,
      title: title,
      description: description,
      type: type,
      transactionType: transactionType,
      price: price,
      surface: surface,
      rooms: rooms,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
      images: images,
      ownerId: ownerId,
      ownerName: ownerName,
      ownerPhone: ownerPhone,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt,
    );
  }
}