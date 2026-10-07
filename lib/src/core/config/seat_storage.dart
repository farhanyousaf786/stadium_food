import 'package:hive/hive.dart';

/// Persist seat / QR prefill data (matches web seatStorage).
class SeatStorage {
  static const _key = 'seatInfo';
  static const _pendingKey = 'pending_seat_data';

  static Box get _box => Hive.box('myBox');

  static Map<String, dynamic> getSeatInfo() {
    final raw = _box.get(_key);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  static void setSeatInfo(Map<String, dynamic> info) {
    final merged = {...getSeatInfo(), ...info};
    merged.removeWhere((k, v) => v == null || v.toString().trim().isEmpty);
    _box.put(_key, merged);
  }

  static Map<String, dynamic> takePendingSeatData() {
    final raw = _box.get(_pendingKey);
    _box.delete(_pendingKey);
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return {};
  }

  static void setPendingSeatData(Map<String, dynamic> info) {
    _box.put(_pendingKey, info);
  }

  /// Parse a QR / deep-link URL into seat fields.
  static Map<String, String> parseSeatUrl(String result) {
    Uri? uri = Uri.tryParse(result);
    if (uri == null || uri.queryParameters.isEmpty) {
      try {
        uri = Uri.parse(result.contains('?') ? result : '?$result');
      } catch (_) {
        return {};
      }
    }
    final qp = uri.queryParameters;
    String? pick(List<String> keys) {
      for (final k in keys) {
        final v = qp[k];
        if (v != null && v.trim().isNotEmpty) return v.trim();
      }
      return null;
    }

    final out = <String, String>{};
    final row = pick(['row', 'Row', 'r']);
    final seat = pick(['seat', 'Seat', 'seatNo', 's']);
    final section = pick(['section', 'Section']);
    final sectionId = pick(['sectionId', 'SectionId', 'sid']);
    final stand = pick(['stand', 'Stand']);
    final floor = pick(['floor', 'Floor']);
    final room = pick(['room', 'Room']);
    final stadiumId = pick(['stadiumId', 'stadium', 'sid_stadium']);
    if (row != null) out['row'] = row;
    if (seat != null) out['seatNo'] = seat;
    if (section != null) out['section'] = section;
    if (sectionId != null) out['sectionId'] = sectionId;
    if (stand != null) out['stand'] = stand;
    if (floor != null) out['floor'] = floor;
    if (room != null) out['room'] = room;
    if (stadiumId != null) out['stadiumId'] = stadiumId;
    return out;
  }
}
