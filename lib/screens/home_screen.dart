import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'identity_verification_screen.dart';
import 'order_confirmation_screen.dart';
import 'provider_home_screen.dart';
import 'rating_screen.dart';
import 'subscription_screen.dart';
import 'trip_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _lariImage =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=240';

  static const professionals = [
    Professional(
      name: 'Lari (Manicure)',
      specialty: 'Nail Artist',
      price: 'R\$ 60,00',
      rating: 4.9,
      services: 834,
      imageUrl: _lariImage,
      avatarColor: Color(0xFF597BFF),
    ),
    Professional(
      name: 'Fernanda Lima',
      specialty: 'Design de Sobrancelha',
      price: 'R\$ 65',
      rating: 4.8,
      services: 612,
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=240',
      avatarColor: Color(0xFFAC6A55),
    ),
    Professional(
      name: 'Juliana Melo',
      specialty: 'Cabeleireira',
      price: 'R\$ 120',
      rating: 4.9,
      services: 1204,
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=240',
      avatarColor: Color(0xFF3A90BD),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedMobileBody(
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('home-scroll'),
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
          children: [
            const _LocationHeader(),
            const SizedBox(height: 12),
            const _PointsCard(),
            const SizedBox(height: 18),
            const SectionTitle(title: 'Serviços', action: 'Ver todos  ›'),
            const SizedBox(height: 8),
            const _ServicesGrid(),
            const SizedBox(height: 18),
            const SectionTitle(title: 'Parceiros Perto de Você', action: 'Ver todos  ›'),
            const SizedBox(height: 8),
            const _PartnersRow(),
            const SizedBox(height: 14),
            const SectionTitle(title: 'Acessos Rápidos'),
            const SizedBox(height: 8),
            _FeatureBanner(
              icon: Icons.route_rounded,
              iconColor: AppColors.primary,
              title: 'Trajeto e Mensagens Rápidas',
              subtitle: 'Mapa, chegada e ações por toque',
              trailing: const StatusPill(label: 'CLIENTE'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TripScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _FeatureBanner(
              icon: Icons.star_outline_rounded,
              iconColor: AppColors.purple,
              title: 'Avaliação Mútua',
              subtitle: 'Nota, destaques e relato da experiência',
              trailing: const StatusPill(label: 'PÓS-SERVIÇO', color: AppColors.purple),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RatingScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _FeatureBanner(
              icon: Icons.workspace_premium_outlined,
              iconColor: AppColors.green,
              title: 'Plano Profissional',
              subtitle: 'Assinatura sem comissão por atendimento',
              trailing: const StatusPill(label: 'PRESTADORA', color: AppColors.green),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _FeatureBanner(
              icon: Icons.verified_user_outlined,
              iconColor: AppColors.primary,
              title: 'Verificar Identidade',
              subtitle: 'ID Check · Segurança',
              trailing: const StatusPill(label: 'PENDENTE'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const IdentityVerificationScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _FeatureBanner(
              icon: Icons.business_center_outlined,
              iconColor: AppColors.primary,
              title: 'Área da Prestadora',
              subtitle: 'Ganhos, agenda e segurança',
              gradient: const LinearGradient(
                colors: [Color(0xFF32103B), Color(0xFF52116B)],
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProviderHomeScreen()),
              ),
            ),
            const SizedBox(height: 18),
            const SectionTitle(
              title: 'Profissionais em Destaque',
              action: 'Ver todos  ›',
            ),
            const SizedBox(height: 8),
            ...professionals.map(
              (professional) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _ProfessionalTile(
                  professional: professional,
                  onTap: professional.name == 'Lari (Manicure)'
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OrderConfirmationScreen(),
                            ),
                          )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const _OfferCard(),
          ],
        ),
      ),
    );
  }
}

class _LocationHeader extends StatelessWidget {
  const _LocationHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SUA LOCALIZAÇÃO', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              const Row(
                children: [
                  Flexible(
                    child: Text(
                      'R. Izabel A Redentora, 1000',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 17),
                ],
              ),
              const Text(
                'Centro — São José dos Pinhais, PR',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
              ),
            ],
          ),
        ),
        const _HeaderAction(icon: Icons.notifications_none_rounded),
        const SizedBox(width: 8),
        const ProfileAvatar(
          imageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=180',
          size: 38,
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 18, color: AppColors.textSecondary),
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard();

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      borderColor: Colors.transparent,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFCA2DB0), Color(0xFF7138E3)],
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.purple.withValues(alpha: .2),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, size: 13, color: AppColors.yellow),
                        SizedBox(width: 5),
                        Text(
                          'REDGLOW PONTOS',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text('2.480', style: Theme.of(context).textTheme.headlineMedium),
                    const Text(
                      'pontos acumulados',
                      style: TextStyle(color: Colors.white70, fontSize: 9),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Column(
                  children: [
                    Text('Próximo', style: TextStyle(fontSize: 8, color: Colors.white70)),
                    Text('R\$ 25', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Text('em 520 pts', style: TextStyle(fontSize: 7, color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: Text('Meta: 3.000 pts', style: TextStyle(fontSize: 8))),
              Text('82,6%', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: .826,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(AppColors.yellow),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _PointsButton(
                  label: 'Resgatar',
                  background: Colors.white.withValues(alpha: .2),
                  foreground: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _PointsButton(
                  label: 'Ver Histórico',
                  background: Colors.white,
                  foreground: Color(0xFF6C2ED0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '+25 pontos neste fim de semana em serviços de unhas!',
            style: TextStyle(fontSize: 8, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _PointsButton extends StatelessWidget {
  const _PointsButton({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid();

  static const items = [
    (Icons.back_hand_rounded, 'Unhas'),
    (Icons.auto_awesome_rounded, 'Sobrancelha'),
    (Icons.face_3_rounded, 'Cabelo'),
    (Icons.colorize_rounded, 'Maquiagem'),
    (Icons.spa_rounded, 'Depilação'),
    (Icons.self_improvement_rounded, 'Massagem'),
    (Icons.medication_liquid_rounded, 'Skincare'),
    (Icons.visibility_rounded, 'Cílios'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 30) / 4;
        return Wrap(
          spacing: 10,
          runSpacing: 12,
          children: items
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: Column(
                    children: [
                      Container(
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Center(
                          child: Icon(item.$1, color: AppColors.primary, size: 24),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PartnersRow extends StatelessWidget {
  const _PartnersRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 172,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _PartnerCard(
            title: 'Studio Bella',
            category: 'Unhas e Sobrancelha',
            distance: '0,8 km',
            discount: '20% off',
            imageUrl: 'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=600',
          ),
          SizedBox(width: 10),
          _PartnerCard(
            title: 'Glam House',
            category: 'Cabelo e Maquiagem',
            distance: '1,2 km',
            discount: '15% off',
            imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=600',
          ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({
    required this.title,
    required this.category,
    required this.distance,
    required this.discount,
    required this.imageUrl,
  });

  final String title;
  final String category;
  final String distance;
  final String discount;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const ColoredBox(
                    color: AppColors.surfaceRaised,
                    child: Icon(Icons.storefront_rounded, color: AppColors.textMuted),
                  ),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xAA0B0911)],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: StatusPill(label: discount, color: AppColors.primary),
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
                ),
                Positioned(
                  left: 8,
                  bottom: 7,
                  child: Text(
                    distance,
                    style: const TextStyle(fontSize: 8, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                Text(category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.star_rounded, color: AppColors.yellow, size: 12),
                    Text(' 4,9', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700)),
                    SizedBox(width: 10),
                    Icon(Icons.shield_outlined, color: AppColors.purple, size: 11),
                    Text(' 120 avaliações', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBanner extends StatelessWidget {
  const _FeatureBanner({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.gradient,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      gradient: gradient,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      borderColor: AppColors.primary.withValues(alpha: .4),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .12),
              shape: BoxShape.circle,
              border: Border.all(color: iconColor.withValues(alpha: .55)),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
          const SizedBox(width: 5),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _ProfessionalTile extends StatelessWidget {
  const _ProfessionalTile({required this.professional, this.onTap});

  final Professional professional;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.all(9),
      radius: AppRadius.md,
      child: Row(
        children: [
          ProfileAvatar(
            imageUrl: professional.imageUrl,
            size: 52,
            borderColor: professional.avatarColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(professional.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                Text(professional.specialty, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 12, color: AppColors.yellow),
                    Text(' ${professional.rating}', style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Text('◉ ${professional.services} serviços', style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                professional.price,
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const StatusPill(label: 'Disponível', color: AppColors.green),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        gradient: const LinearGradient(
          colors: [Color(0xFFC22A9F), Color(0xFF6428A3)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('OFERTA ESPECIAL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
                const Text('Primeira sessão', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                const Text('50% OFF', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(99)),
                  child: const Text('Aproveitar agora  →', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          Icon(Icons.spa_rounded, size: 74, color: Colors.white.withValues(alpha: .12)),
        ],
      ),
    );
  }
}
