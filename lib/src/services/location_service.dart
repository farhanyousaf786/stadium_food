import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static Future<void> checkLocationPermission() async {
    // Check if location service is enabled
    if (!await Permission.location.serviceStatus.isEnabled) {
      throw Exception('location_service_disabled');
    }

    // Request permission
    final status = await Permission.location.request();
    
    if (status.isDenied) {
      throw Exception('location_permission_denied');
    }
    
    if (status.isPermanentlyDenied) {
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

  Future<String?> getNearestDeliveryUser(double maxDistance) async {
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
      
      final List<dynamic> location = userData['location'];
      if (location.length != 2) continue;

      final distance = calculateDistance(
        position.latitude,
        position.longitude,
        location[0],
        location[1],
      );

      if (distance <= maxDistance && distance < minDistance) {
        minDistance = distance;
        nearestUserId = doc.id;
      }
    }

    return nearestUserId.isEmpty ? null : nearestUserId;
  }
}
