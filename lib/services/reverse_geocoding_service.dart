import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Reverse geocoding leve para o beta.
///
/// A consulta acontece somente depois do consentimento de localização, é
/// serializada, limitada e mantida em cache durante a sessão. Antes da
/// produção, este endpoint público deve ser substituído por um provedor com
/// SLA e contrato próprios.
class ReverseGeocodingService {
  ReverseGeocodingService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static final Map<String, String> _cache = <String, String>{};
  static Future<void> _requestQueue = Future<void>.value();
  static DateTime? _lastRequestAt;

  Future<String?> resolve({
    required double latitude,
    required double longitude,
  }) async {
    final key = '${latitude.toStringAsFixed(5)},${longitude.toStringAsFixed(5)}';
    final cached = _cache[key];
    if (cached != null) return cached;

    final completer = Completer<String?>();
    _requestQueue = _requestQueue.then((_) async {
      final lastRequestAt = _lastRequestAt;
      if (lastRequestAt != null) {
        final elapsed = DateTime.now().difference(lastRequestAt);
        if (elapsed < const Duration(seconds: 1)) {
          await Future<void>.delayed(const Duration(seconds: 1) - elapsed);
        }
      }
      _lastRequestAt = DateTime.now();

      try {
        final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
          'format': 'jsonv2',
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'zoom': '18',
          'addressdetails': '1',
          'accept-language': 'pt-BR',
        });
        final response = await _client.get(
          uri,
          headers: {
            'Accept': 'application/json',
            if (!kIsWeb)
              'User-Agent':
                  'REDGLOW-Beta/7.0.8 (+https://github.com/rdiasntac-dev/redglow)',
          },
        ).timeout(const Duration(seconds: 8));
        if (response.statusCode != 200) {
          completer.complete(null);
          return;
        }
        final decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          completer.complete(null);
          return;
        }
        final address = decoded['address'];
        final addressData = address is Map
            ? Map<String, dynamic>.from(address)
            : const <String, dynamic>{};
        final label = _formatAddress(addressData, decoded['display_name']);
        if (label == null) {
          completer.complete(null);
          return;
        }
        _cache[key] = label;
        completer.complete(label);
      } catch (_) {
        completer.complete(null);
      }
    });
    await _requestQueue;
    return completer.future;
  }

  static String? _formatAddress(
    Map<String, dynamic> address,
    Object? displayName,
  ) {
    String? first(List<String> keys) {
      for (final key in keys) {
        final value = address[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return null;
    }

    final road = first(['road', 'pedestrian', 'residential', 'path']);
    final number = first(['house_number']);
    final district = first(['suburb', 'neighbourhood', 'quarter']);
    final city = first(['city', 'town', 'municipality', 'village']);
    final street = [road, number]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .join(', ');
    final locality = [district, city]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .toSet()
        .join(', ');
    final formatted = [street, locality]
        .where((part) => part.isNotEmpty)
        .join(' — ')
        .trim();
    if (formatted.isNotEmpty) return formatted;

    final fallback = displayName?.toString().trim();
    if (fallback == null || fallback.isEmpty) return null;
    return fallback.length <= 160 ? fallback : '${fallback.substring(0, 157)}...';
  }
}
