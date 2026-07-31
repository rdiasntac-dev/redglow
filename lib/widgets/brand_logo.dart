import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Marca vetorial do REDGLOW.
///
/// O símbolo combina um pin (beleza que vai até a pessoa), uma pétala e
/// um brilho protegido no centro. Evita clichês de boca ou esmalte e funciona
/// tanto no aplicativo quanto em ícone reduzido.
class RedGlowBrandMark extends StatelessWidget {
  const RedGlowBrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .3),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF4DA2), Color(0xFFB62DCA), Color(0xFF6534D9)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: .28),
              blurRadius: size * .38,
              offset: Offset(0, size * .12),
            ),
          ],
        ),
        child: CustomPaint(painter: _RedGlowMarkPainter()),
      ),
    );
  }
}

class RedGlowBrandLockup extends StatelessWidget {
  const RedGlowBrandLockup({
    super.key,
    this.markSize = 72,
    this.showTagline = true,
  });

  final double markSize;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RedGlowBrandMark(size: markSize),
        SizedBox(height: markSize * .18),
        const Text(
          'REDGLOW',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          const Text(
            'Beleza que chega até você, com segurança.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _RedGlowMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2;

    final petalPin = Path()
      ..moveTo(cx, size.height * .76)
      ..cubicTo(
        size.width * .18,
        size.height * .53,
        size.width * .25,
        size.height * .20,
        cx,
        size.height * .18,
      )
      ..cubicTo(
        size.width * .75,
        size.height * .20,
        size.width * .82,
        size.height * .53,
        cx,
        size.height * .76,
      )
      ..close();
    canvas.drawPath(petalPin, white);

    final orbit = Paint()
      ..color = Colors.white.withValues(alpha: .48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .035;
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(cx, size.height * .43),
        width: size.width * .34,
        height: size.height * .34,
      ),
      -.8,
      4.9,
      false,
      orbit,
    );

    final glow = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final star = Path()
      ..moveTo(cx, size.height * .29)
      ..lineTo(cx + size.width * .045, size.height * .40)
      ..lineTo(cx + size.width * .15, size.height * .44)
      ..lineTo(cx + size.width * .045, size.height * .48)
      ..lineTo(cx, size.height * .59)
      ..lineTo(cx - size.width * .045, size.height * .48)
      ..lineTo(cx - size.width * .15, size.height * .44)
      ..lineTo(cx - size.width * .045, size.height * .40)
      ..close();
    canvas.drawPath(star, glow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
