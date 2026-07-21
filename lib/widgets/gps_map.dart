import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'common_widgets.dart';

class UrbanGpsMap extends StatelessWidget {
  const UrbanGpsMap({
    super.key,
    this.showProviderChip = false,
    this.showEtaChip = true,
    this.compactRoute = false,
  });

  final bool showProviderChip;
  final bool showEtaChip;
  final bool compactRoute;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _UrbanMapPainter(compactRoute: compactRoute)),
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
          alignment: compactRoute ? const Alignment(.08, -.35) : const Alignment(.04, -.18),
          child: const _DestinationMarker(),
        ),
        Align(
          alignment: compactRoute ? const Alignment(.5, -.82) : const Alignment(-.35, -.43),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.purple.withOpacity(.5), blurRadius: 12),
              ],
            ),
          ),
        ),
        if (showProviderChip)
          const Positioned(
            top: 18,
            right: 16,
            child: _ProviderMapChip(),
          ),
        if (showEtaChip)
          const Positioned(
            bottom: 22,
            left: 0,
            right: 0,
            child: Center(
              child: StatusPill(
                label: 'Prestadora a ~8 min de você',
                color: AppColors.primary,
                icon: Icons.directions_car_filled_rounded,
              ),
            ),
          ),
      ],
    );
  }
}

class _ProviderMapChip extends StatelessWidget {
  const _ProviderMapChip();

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      radius: 12,
      borderColor: AppColors.green.withOpacity(.45),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lari (Manicure)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
              Row(
                children: [
                  SizedBox(
                    width: 6,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('A caminho', style: TextStyle(fontSize: 7, color: AppColors.green)),
                ],
              ),
            ],
          ),
          SizedBox(width: 8),
          ProfileAvatar(
            imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=180',
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
                  color: AppColors.primary.withOpacity(.1),
                ),
              ),
              Container(
                width: 42 * value,
                height: 42 * value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(.24),
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
                    BoxShadow(color: AppColors.primary.withOpacity(.7), blurRadius: 14),
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
      ..color = AppColors.route.withOpacity(.18)
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
