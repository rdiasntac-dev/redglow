import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(
      icon: Icons.search_rounded,
      title: 'Encontre seu serviço',
      subtitle: 'A busca por profissionais será conectada à API nesta etapa.',
    );
  }
}

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(
      icon: Icons.calendar_month_rounded,
      title: 'Seus agendamentos',
      subtitle: 'Os próximos atendimentos aparecerão aqui.',
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedMobileBody(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),
            Text('Meu perfil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            const GlowCard(
              child: Row(
                children: [
                  ProfileAvatar(
                    imageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=180',
                    size: 64,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cliente REDGLOW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        Text('Identidade pendente', style: TextStyle(color: AppColors.primary, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final item in const [
              (Icons.location_on_outlined, 'Endereços'),
              (Icons.payments_outlined, 'Formas de pagamento'),
              (Icons.shield_outlined, 'Segurança e privacidade'),
              (Icons.help_outline_rounded, 'Ajuda'),
            ])
              GlowCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(item.$1, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item.$2)),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: .5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Sair da conta demonstrativa',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedMobileBody(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: .5)),
                  ),
                  child: Icon(icon, size: 34, color: AppColors.primary),
                ),
                const SizedBox(height: 18),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
