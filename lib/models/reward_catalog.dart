import 'package:flutter/material.dart';

class RedGlowReward {
  const RedGlowReward({
    required this.id,
    required this.name,
    required this.partnerName,
    required this.description,
    required this.pointsCost,
    required this.icon,
    required this.colors,
  });

  final String id;
  final String name;
  final String partnerName;
  final String description;
  final int pointsCost;
  final IconData icon;
  final List<Color> colors;
}

abstract final class RedGlowRewardCatalog {
  static const rewards = <RedGlowReward>[
    RedGlowReward(
      id: 'earrings-demo',
      name: 'Par de brincos Glow',
      partnerName: 'Parceira Bella Acessórios',
      description:
          'Recompensa piloto para validar saldo, reserva e retirada com um parceiro local.',
      pointsCost: 10,
      icon: Icons.diamond_outlined,
      colors: [Color(0xFFE8408C), Color(0xFF8D3DDB)],
    ),
  ];
}
