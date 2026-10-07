import 'dart:math' as math;

import 'package:stadium_food/src/data/models/stadium.dart';

/// Matches web `geoLocation.js` nearest-venue helpers.
class StadiumGeo {
  /// Default max distance for auto-selecting a venue (km) — web NEAREST_VENUE_MAX_KM.
  static const double nearestVenueMaxKm = 200;

  static ({double latitude, double longitude})? coordsOf(Stadium stadium) {
    final lat = stadium.latitude;
    final lng = stadium.longitude;
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return (latitude: lat, longitude: lng);
  }

  static double distanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    double toRad(double deg) => deg * math.pi / 180;
    final dLat = toRad(lat2 - lat1);
    final dLon = toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(toRad(lat1)) *
            math.cos(toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static ({Stadium stadium, double distanceKm})? findNearest(
    List<Stadium> stadiums,
    double userLat,
    double userLng, {
    double maxDistanceKm = nearestVenueMaxKm,
  }) {
    ({Stadium stadium, double distanceKm})? best;
    for (final stadium in stadiums) {
      final coords = coordsOf(stadium);
      if (coords == null) continue;
      final d = distanceKm(
        userLat,
        userLng,
        coords.latitude,
        coords.longitude,
      );
      if (d > maxDistanceKm) continue;
      if (best == null || d < best.distanceKm) {
        best = (stadium: stadium, distanceKm: d);
      }
    }
    return best;
  }

  static String formatDistanceKm(double km) {
    if (km < 1) return '${(km * 1000).round()} m';
    if (km < 10) return '${km.toStringAsFixed(1)} km';
    return '${km.round()} km';
  }
}
