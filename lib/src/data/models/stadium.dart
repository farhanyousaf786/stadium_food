import 'package:cloud_firestore/cloud_firestore.dart';

class Stadium {
  final String id;
  final String name;
  final String about;
  final String location;
  final int capacity;
  final String imageUrl;
  final String createdAt;
  final String updatedAt;

  /// Venue branding (matches web stadium theme fields)
  final String color;
  final String secondaryColor;
  final String brandName;
  final String logoUrl;
  final String bannerUrl;

  /// Seat / delivery feature flags (admin dashboard)
  final bool availableSeats;
  final bool availableSections;
  final bool availableFloors;
  final bool availableRooms;
  final bool availablePickupPoints;
  final bool availableStands;
  final bool availableTickets;
  final int floors;

  /// Geo for nearest-venue auto-select
  final double? latitude;
  final double? longitude;

  Stadium({
    required this.id,
    required this.name,
    required this.about,
    required this.location,
    required this.capacity,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.color = '',
    this.secondaryColor = '',
    this.brandName = '',
    this.logoUrl = '',
    this.bannerUrl = '',
    this.availableSeats = true,
    this.availableSections = true,
    this.availableFloors = false,
    this.availableRooms = false,
    this.availablePickupPoints = false,
    this.availableStands = false,
    this.availableTickets = false,
    this.floors = 0,
    this.latitude,
    this.longitude,
  });

  factory Stadium.fromMap(String id, Map<String, dynamic> map) {
    return Stadium(
      id: id,
      name: map['name'] ?? '',
      about: map['about'] ?? '',
      location: map['location'] ?? '',
      capacity: map['capacity'] ?? 0,
      imageUrl: map['imageUrl'] ?? map['bannerUrl'] ?? '',
      createdAt: _asString(map['createdAt']),
      updatedAt: _asString(map['updatedAt']),
      color: map['color']?.toString() ?? '',
      secondaryColor: map['secondaryColor']?.toString() ?? '',
      brandName: map['brandName']?.toString() ?? '',
      logoUrl: map['logoUrl']?.toString() ?? '',
      bannerUrl: map['bannerUrl']?.toString() ?? '',
      availableSeats: map['availableSeats'] ?? true,
      availableSections: map['availableSections'] ?? true,
      availableFloors: map['availableFloors'] ?? false,
      availableRooms: map['availableRooms'] ?? false,
      availablePickupPoints: map['availablePickupPoints'] ?? false,
      availableStands: map['availableStands'] ?? false,
      availableTickets: map['availableTickets'] ?? false,
      floors: (map['floors'] as num?)?.toInt() ??
          int.tryParse(map['floors']?.toString() ?? '') ??
          0,
      latitude: _readCoord(map, isLat: true),
      longitude: _readCoord(map, isLat: false),
    );
  }

  Map<String, dynamic> toHiveMap() {
    return {
      'id': id,
      'name': name,
      'about': about,
      'location': location,
      'capacity': capacity,
      'imageUrl': imageUrl,
      'color': color,
      'secondaryColor': secondaryColor,
      'brandName': brandName,
      'logoUrl': logoUrl,
      'bannerUrl': bannerUrl,
      'availableSeats': availableSeats,
      'availableSections': availableSections,
      'availableFloors': availableFloors,
      'availableRooms': availableRooms,
      'availablePickupPoints': availablePickupPoints,
      'availableStands': availableStands,
      'availableTickets': availableTickets,
      'floors': floors,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Stadium.fromHiveMap(Map map) {
    return Stadium(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      about: map['about']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl']?.toString() ?? '',
      createdAt: '',
      updatedAt: '',
      color: map['color']?.toString() ?? '',
      secondaryColor: map['secondaryColor']?.toString() ?? '',
      brandName: map['brandName']?.toString() ?? '',
      logoUrl: map['logoUrl']?.toString() ?? '',
      bannerUrl: map['bannerUrl']?.toString() ?? '',
      availableSeats: map['availableSeats'] ?? true,
      availableSections: map['availableSections'] ?? true,
      availableFloors: map['availableFloors'] ?? false,
      availableRooms: map['availableRooms'] ?? false,
      availablePickupPoints: map['availablePickupPoints'] ?? false,
      availableStands: map['availableStands'] ?? false,
      availableTickets: map['availableTickets'] ?? false,
      floors: (map['floors'] as num?)?.toInt() ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is Timestamp) return value.toDate().toIso8601String();
    return value.toString();
  }

  static double? _readCoord(Map<String, dynamic> map, {required bool isLat}) {
    dynamic raw = isLat
        ? (map['latitude'] ?? map['lat'])
        : (map['longitude'] ?? map['lng'] ?? map['lon']);

    if (raw == null && map['geo'] is Map) {
      final geo = Map<String, dynamic>.from(map['geo'] as Map);
      raw = isLat
          ? (geo['latitude'] ?? geo['lat'])
          : (geo['longitude'] ?? geo['lng']);
    }
    if (raw == null && map['coordinates'] is Map) {
      final c = Map<String, dynamic>.from(map['coordinates'] as Map);
      raw = isLat
          ? (c['latitude'] ?? c['lat'])
          : (c['longitude'] ?? c['lng']);
    }
    if (raw is GeoPoint) {
      return isLat ? raw.latitude : raw.longitude;
    }
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw);
    return null;
  }
}
