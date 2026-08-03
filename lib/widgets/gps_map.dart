import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/road_route_service.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class UrbanGpsMap extends StatefulWidget {
  const UrbanGpsMap({
    super.key,
    this.showProviderChip = false,
    this.showEtaChip = true,
    this.compactRoute = false,
    this.providerName = 'Prestadora REDGLOW',
    this.providerPhotoUrl = '',
    this.etaMinutes,
    this.liveLocation = false,
    this.providerLatitude,
    this.providerLongitude,
    this.destinationLatitude,
    this.destinationLongitude,
    this.destinationLabel = 'Destino confirmado',
  });

  final bool showProviderChip;
  final bool showEtaChip;
  final bool compactRoute;
  final String providerName;
  final String providerPhotoUrl;
  final int? etaMinutes;
  final bool liveLocation;
  final double? providerLatitude;
  final double? providerLongitude;
  final double? destinationLatitude;
  final double? destinationLongitude;
  final String destinationLabel;

  bool get hasRealCoordinates =>
      providerLatitude != null &&
      providerLongitude != null &&
      destinationLatitude != null &&
      destinationLongitude != null;

  @override
  State<UrbanGpsMap> createState() => _UrbanGpsMapState();
}

class _UrbanGpsMapState extends State<UrbanGpsMap> {
  final RoadRouteService _routeService = RoadRouteService();
  Future<RoadRoute?>? _routeFuture;

  @override
  void initState() {
    super.initState();
    _refreshRoute();
  }

  @override
  void didUpdateWidget(covariant UrbanGpsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.providerLatitude != widget.providerLatitude ||
        oldWidget.providerLongitude != widget.providerLongitude ||
        oldWidget.destinationLatitude != widget.destinationLatitude ||
        oldWidget.destinationLongitude != widget.destinationLongitude) {
      _refreshRoute();
    }
  }

  void _refreshRoute() {
    if (!widget.hasRealCoordinates) {
      _routeFuture = null;
      return;
    }
    _routeFuture = _routeService.route(
      fromLatitude: widget.providerLatitude!,
      fromLongitude: widget.providerLongitude!,
      toLatitude: widget.destinationLatitude!,
      toLongitude: widget.destinationLongitude!,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hasRealCoordinates) {
      return _RealGpsMap(widget: widget, routeFuture: _routeFuture!);
    }
    return _SimulatedGpsMap(widget: widget);
  }
}

class _SimulatedGpsMap extends StatelessWidget {
  const _SimulatedGpsMap({required this.widget});

  final UrbanGpsMap widget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: _UrbanMapPainter(compactRoute: widget.compactRoute),
        ),
        const Positioned(
          left: 12,
          top: 82,
          child: _MapLabel(label: 'Av. Rui Barbosa'),
        ),
        const Positioned(
          left: 10,
          top: 205,
          child: _MapLabel(label: 'Av. das Torres'),
        ),
        const Positioned(
          left: 8,
          top: 288,
          child: _MapLabel(label: 'R. Izabel A Redentora'),
        ),
        const Positioned(
          left: 8,
          bottom: 118,
          child: _MapLabel(label: 'Av. Manoel Ribas'),
        ),
        Align(
          alignment: widget.compactRoute
              ? const Alignment(.08, -.35)
              : const Alignment(.04, -.18),
          child: const _DestinationMarker(),
        ),
        Align(
          alignment: widget.compactRoute
              ? const Alignment(.5, -.82)
              : const Alignment(-.35, -.43),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.purple.withValues(alpha: .5), blurRadius: 12),
              ],
            ),
          ),
        ),
        if (widget.showProviderChip)
          Positioned(
            top: 18,
            right: 16,
            child: _ProviderMapChip(
              providerName: widget.providerName,
              providerPhotoUrl: widget.providerPhotoUrl,
              liveLocation: widget.liveLocation,
            ),
          ),
        if (widget.showEtaChip)
          Positioned(
            bottom: 22,
            left: 0,
            right: 0,
            child: Center(
              child: StatusPill(
                label: widget.etaMinutes == null
                    ? 'Rota simulada · aguardando GPS'
                    : 'Prestadora a ~${widget.etaMinutes} min de você',
                color: widget.etaMinutes == null
                    ? AppColors.textMuted
                    : AppColors.primary,
                icon: widget.etaMinutes == null
                    ? Icons.location_searching_rounded
                    : Icons.directions_car_filled_rounded,
              ),
            ),
          ),
      ],
    );
  }
}

class _RealGpsMap extends StatelessWidget {
  const _RealGpsMap({
    required this.widget,
    required this.routeFuture,
  });

  final UrbanGpsMap widget;
  final Future<RoadRoute?> routeFuture;

  @override
  Widget build(BuildContext context) {
    final provider = LatLng(
      widget.providerLatitude!,
      widget.providerLongitude!,
    );
    final destination = LatLng(
      widget.destinationLatitude!,
      widget.destinationLongitude!,
    );
    final center = LatLng(
      (provider.latitude + destination.latitude) / 2,
      (provider.longitude + destination.longitude) / 2,
    );
    final span = math.max(
      (provider.latitude - destination.latitude).abs(),
      (provider.longitude - destination.longitude).abs(),
    );
    final zoom = span <= .003
        ? 16.0
        : span <= .008
            ? 14.7
            : span <= .02
                ? 13.3
                : span <= .06
                    ? 11.8
                    : 10.2;

    return FutureBuilder<RoadRoute?>(
      future: routeFuture,
      builder: (context, snapshot) {
        final route = snapshot.data;
        final points = route?.points
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList(growable: false) ??
            <LatLng>[provider, destination];
        final eta = route?.durationMinutes ?? widget.etaMinutes;
        return Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: zoom,
                minZoom: 4,
                maxZoom: 19,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'br.com.redglow.app',
                  tileBuilder: darkModeTileBuilder,
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: points,
                      strokeWidth: 9,
                      color: AppColors.route.withValues(alpha: .2),
                    ),
                    Polyline(
                      points: points,
                      strokeWidth: 4.5,
                      color: AppColors.route,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: provider,
                      width: 48,
                      height: 48,
                      child: _ProviderMarker(
                        photoUrl: widget.providerPhotoUrl,
                        name: widget.providerName,
                      ),
                    ),
                    Marker(
                      point: destination,
                      width: 74,
                      height: 74,
                      child: const _DestinationMarker(),
                    ),
                  ],
                ),
              ],
            ),
            if (widget.showProviderChip)
              Positioned(
                top: 18,
                right: 16,
                child: _ProviderMapChip(
                  providerName: widget.providerName,
                  providerPhotoUrl: widget.providerPhotoUrl,
                  liveLocation: true,
                ),
              ),
            Positioned(
              left: 10,
              top: 10,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 205),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: .88),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Text(
                      widget.destinationLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: TextButton(
                onPressed: () => launchUrl(
                  Uri.parse('https://www.openstreetmap.org/copyright'),
                  mode: LaunchMode.externalApplication,
                ),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.background.withValues(alpha: .82),
                  foregroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('© OpenStreetMap', style: TextStyle(fontSize: 7)),
              ),
            ),
            if (widget.showEtaChip)
              Positioned(
                bottom: 18,
                left: 0,
                right: 0,
                child: Center(
                  child: StatusPill(
                    label: snapshot.connectionState == ConnectionState.waiting
                        ? 'Calculando rota real...'
                        : eta == null
                            ? 'GPS confirmado · ETA indisponível'
                            : 'Rota viária · aproximadamente $eta min',
                    color: eta == null ? AppColors.textMuted : AppColors.primary,
                    icon: eta == null
                        ? Icons.location_on_outlined
                        : Icons.directions_car_filled_rounded,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProviderMarker extends StatelessWidget {
  const _ProviderMarker({required this.photoUrl, required this.name});

  final String photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ProfileAvatar(
      imageUrl: photoUrl,
      fallbackText: name,
      size: 42,
      borderColor: AppColors.purple,
    );
  }
}

class _ProviderMapChip extends StatelessWidget {
  const _ProviderMapChip({
    required this.providerName,
    required this.providerPhotoUrl,
    required this.liveLocation,
  });

  final String providerName;
  final String providerPhotoUrl;
  final bool liveLocation;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      radius: 12,
      borderColor: AppColors.green.withValues(alpha: .45),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                providerName,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 6,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    liveLocation ? 'GPS atualizado' : 'Rota estimada',
                    style: const TextStyle(
                      fontSize: 7,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          ProfileAvatar(
            imageUrl: providerPhotoUrl,
            fallbackText: providerName,
            size: 30,
            borderColor: AppColors.green,
          ),
        ],
      ),
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .75, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 74,
          height: 74,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 70 * value,
                height: 70 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: .1),
                ),
              ),
              Container(
                width: 42 * value,
                height: 42 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: .24),
                ),
              ),
              Container(
                width: 21,
                height: 21,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: .7), blurRadius: 14),
                  ],
                ),
                child: const Icon(Icons.location_on_rounded, size: 12, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF555A68),
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _UrbanMapPainter extends CustomPainter {
  const _UrbanMapPainter({required this.compactRoute});

  final bool compactRoute;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.mapBackground);

    final blockPaint = Paint()..color = const Color(0xFF20232C);
    final altBlockPaint = Paint()..color = const Color(0xFF22252E);
    final parkPaint = Paint()..color = const Color(0xFF18291F);

    final cellW = size.width / 5;
    final cellH = size.height / 9;
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 5; col++) {
        final inset = 5.0 + ((row + col) % 3);
        final rect = Rect.fromLTWH(
          col * cellW + inset,
          row * cellH + inset,
          cellW - inset * 2,
          cellH - inset * 2,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          (row == 4 && col == 3) ? parkPaint : ((row + col).isEven ? blockPaint : altBlockPaint),
        );
      }
    }

    final minorRoad = Paint()
      ..color = const Color(0xFF282C36)
      ..strokeWidth = 2;
    for (var i = 1; i < 5; i++) {
      canvas.drawLine(Offset(i * cellW, 0), Offset(i * cellW, size.height), minorRoad);
    }
    for (var i = 1; i < 9; i++) {
      canvas.drawLine(Offset(0, i * cellH), Offset(size.width, i * cellH), minorRoad);
    }

    final avenue = Paint()
      ..color = const Color(0xFF303541)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(size.width * .49, 0), Offset(size.width * .49, size.height), avenue);
    canvas.drawLine(Offset(0, size.height * .42), Offset(size.width, size.height * .42), avenue);
    canvas.drawLine(
      Offset(size.width * .18, size.height),
      Offset(size.width, size.height * .33),
      avenue,
    );

    final avenueEdge = Paint()
      ..color = const Color(0xFF242833)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(size.width * .49, 0), Offset(size.width * .49, size.height), avenueEdge);
    canvas.drawLine(Offset(0, size.height * .42), Offset(size.width, size.height * .42), avenueEdge);

    final routeGlow = Paint()
      ..color = AppColors.route.withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final route = Paint()
      ..color = AppColors.route
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (compactRoute) {
      path
        ..moveTo(size.width * .24, size.height * .9)
        ..lineTo(size.width * .49, size.height * .9)
        ..lineTo(size.width * .49, size.height * .33)
        ..lineTo(size.width * .54, size.height * .33);
    } else {
      path
        ..moveTo(0, size.height * .42)
        ..lineTo(size.width * .49, size.height * .42)
        ..lineTo(size.width * .49, size.height * .94);
    }
    canvas.drawPath(path, routeGlow);
    canvas.drawPath(path, route);

    final water = Paint()..color = const Color(0xFF182531);
    final waterPath = Path()
      ..moveTo(size.width * .78, size.height)
      ..quadraticBezierTo(size.width * .91, size.height * .85, size.width, size.height * .8)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(waterPath, water);

    final buildingPaint = Paint()..color = const Color(0xFF292D37);
    final random = math.Random(7);
    for (var i = 0; i < 26; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(x, y, 5 + random.nextDouble() * 9, 3), buildingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _UrbanMapPainter oldDelegate) {
    return oldDelegate.compactRoute != compactRoute;
  }
}
