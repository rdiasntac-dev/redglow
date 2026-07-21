import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'rating_screen.dart';
import 'subscription_screen.dart';
import 'trip_screen.dart';

class FlowsHubScreen extends StatelessWidget {
  const FlowsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedMobileBody(
        child: SafeArea(
          child: Column(
            children: [
              const PageHeader(
                title: 'Novas telas — Versão 7',
                subtitle: 'Fluxos aprovados do REDGLOW',
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                  children: [
                    _FlowCard(
                      number: '1',
                      icon: Icons.route_rounded,
                      color: AppColors.primary,
                      title: 'Trajeto e Mensagens Rápidas',
                      subtitle: 'Mapa urbano, status da prestadora e ações sem chat livre.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TripScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FlowCard(
                      number: '2',
                      icon: Icons.star_rounded,
                      color: AppColors.purple,
                      title: 'Avaliação Mútua e Relato',
                      subtitle: 'Nota, tags rápidas e comentário opcional pós-serviço.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RatingScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FlowCard(
                      number: '3',
                      icon: Icons.workspace_premium_rounded,
                      color: AppColors.green,
                      title: 'Plano Profissional',
                      subtitle: 'Assinatura SaaS com zero comissão por atendimento.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard({
    required this.number,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String number;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacity(.48),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withOpacity(.13),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: color.withOpacity(.45)),
                ),
                child: Icon(icon, color: color, size: 27),
              ),
              Positioned(
                top: -7,
                left: -7,
                child: Container(
                  width: 21,
                  height: 21,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: Text(number, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
