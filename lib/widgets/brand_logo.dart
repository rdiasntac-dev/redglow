import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Marca principal do REDGLOW.
///
/// O monograma combina R + G em uma rota contínua, com um ponto luminoso de
/// encontro. A mesma assinatura é usada no aplicativo e no ícone instalado.
class RedGlowBrandMark extends StatelessWidget {
  const RedGlowBrandMark({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * .25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .22),
            blurRadius: size * .32,
            offset: Offset(0, size * .08),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * .25),
        child: Image.asset(
          'assets/brand/redglow_brand_mark.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          semanticLabel: 'Símbolo REDGLOW',
        ),
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
