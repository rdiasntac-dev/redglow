import 'package:geolocator/geolocator.dart';

import 'reverse_geocoding_service.dart';

class DeviceLocation {
  const DeviceLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.capturedAt,
    this.address,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime capturedAt;
  final String? address;
}

class LocationPermissionException implements Exception {
  const LocationPermissionException(this.message, {this.permanentlyDenied = false});

  final String message;
  final bool permanentlyDenied;

  @override
  String toString() => message;
}

class DeviceLocationService {
  DeviceLocationService({ReverseGeocodingService? reverseGeocoding})
      : _reverseGeocoding = reverseGeocoding ?? ReverseGeocodingService();

  final ReverseGeocodingService _reverseGeocoding;

  Future<DeviceLocation> current({bool resolveAddress = true}) async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const LocationPermissionException(
        'Ative a localização do aparelho para continuar.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationPermissionException(
        'A permissão de localização foi negada.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionException(
        'A localização está bloqueada. Libere o REDGLOW nas configurações do aparelho.',
        permanentlyDenied: true,
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 18),
      ),
    );
    final address = resolveAddress
        ? await _reverseGeocoding.resolve(
            latitude: position.latitude,
            longitude: position.longitude,
          )
        : null;
    return DeviceLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      capturedAt: position.timestamp,
      address: address,
    );
  }

  static int? estimateTravelMinutes({
    required double? fromLatitude,
    required double? fromLongitude,
    required double? toLatitude,
    required double? toLongitude,
  }) {
    if (fromLatitude == null ||
        fromLongitude == null ||
        toLatitude == null ||
        toLongitude == null) {
      return null;
    }
    final meters = Geolocator.distanceBetween(
      fromLatitude,
      fromLongitude,
      toLatitude,
      toLongitude,
    );
    final minutes = (meters / 1000 / 24 * 60).ceil();
    return minutes.clamp(3, 60).toInt();
  }
}
