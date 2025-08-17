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
    await openAppSettings();
  }

  Future<Position> getCurrentLocation() async {
    await checkLocationPermission();
    return await Geolocator.getCurrentPosition();
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }
}
