import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static Future<void> checkLocationPermission() async {
    // Check if location services are enabled on the device (iOS-safe)
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('location_service_disabled');
    }

    // Check current permission state
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('location_permission_denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('location_permission_permanent');
    }
  }

  static Future<void> openLocationSettings() async {
    await AppSettings.openAppSettings();
  }

  Future<Position> getCurrentLocation() async {
    await checkLocationPermission();
    return await Geolocator.getCurrentPosition();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  Future<String?> getNearestDeliveryUser() async {
    final position = await getCurrentLocation();
    final deliveryUsers = await FirebaseFirestore.instance
        .collection('deliveryUsers')
        .where('isActive', isEqualTo: true)
        .get();

    if (deliveryUsers.docs.isEmpty) return null;

    var nearestUserId = '';
    var minDistance = double.infinity;

    for (var doc in deliveryUsers.docs) {
      final userData = doc.data();
      if (userData['location'] == null) continue;
      
      final GeoPoint location = userData['location'];

      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        location.latitude,
        location.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestUserId = doc.id;
      }
    }

    return nearestUserId.isEmpty ? null : nearestUserId;
  }
}
