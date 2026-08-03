import 'dart:convert';

import 'package:http/http.dart' as http;

class RoadRoutePoint {
  const RoadRoutePoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

class RoadRoute {
  const RoadRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<RoadRoutePoint> points;
  final double distanceMeters;
  final double durationSeconds;

  int get durationMinutes =>
      (durationSeconds / 60).ceil().clamp(1, 180).toInt();
}

/// Roteamento viário usado somente no beta fechado.
///
/// O endpoint público não oferece SLA. Antes da operação comercial ele deve
/// ser trocado por um provedor contratado, sem alterar a interface do mapa.
class RoadRouteService {
  RoadRouteService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static final Map<String, RoadRoute> _cache = <String, RoadRoute>{};

  Future<RoadRoute?> route({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) async {
    final key = <double>[
      fromLatitude,
      fromLongitude,
      toLatitude,
      toLongitude,
    ].map((value) => value.toStringAsFixed(5)).join(',');
    final cached = _cache[key];
    if (cached != null) return cached;

    try {
      final coordinates =
          '$fromLongitude,$fromLatitude;$toLongitude,$toLatitude';
      final uri = Uri.https(
        'router.project-osrm.org',
        '/route/v1/driving/$coordinates',
        const {
          'overview': 'full',
          'geometries': 'geojson',
          'steps': 'false',
        },
      );
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final routes = decoded['routes'];
      if (routes is! List || routes.isEmpty || routes.first is! Map) {
        return null;
      }
      final first = Map<String, dynamic>.from(routes.first as Map);
      final geometry = first['geometry'];
      if (geometry is! Map) return null;
      final coordinatesList = geometry['coordinates'];
      if (coordinatesList is! List) return null;
      final points = coordinatesList
          .whereType<List>()
          .where((coordinate) => coordinate.length >= 2)
          .map(
            (coordinate) => RoadRoutePoint(
              (coordinate[1] as num).toDouble(),
              (coordinate[0] as num).toDouble(),
            ),
          )
          .toList(growable: false);
      if (points.length < 2) return null;

      final route = RoadRoute(
        points: points,
        distanceMeters: (first['distance'] as num?)?.toDouble() ?? 0,
        durationSeconds: (first['duration'] as num?)?.toDouble() ?? 0,
      );
      _cache[key] = route;
      return route;
    } catch (_) {
      return null;
    }
  }
}
