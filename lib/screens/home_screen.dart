import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'identity_verification_screen.dart';
import 'order_confirmation_screen.dart';
import 'rating_screen.dart';
import 'trip_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onExplore,
    this.onBookings,
  });

  final VoidCallback? onExplore;
  final VoidCallback? onBookings;

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
    final demoState = DemoAppScope.of(context);
    final canTrack = {
      DemoBookingStatus.onTheWay,
      DemoBookingStatus.inProgress,
    }.contains(demoState.bookingStatus);
    final canReview = demoState.bookingStatus == DemoBookingStatus.completed;

    return ConstrainedMobileBody(
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('home-scroll'),
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
          children: [
            const _LocationHeader(),
            const SizedBox(height: 12),
            _PointsCard(points: demoState.points),
            const SizedBox(height: 18),
            SectionTitle(
              title: 'Serviços',
              action: 'Ver todos  ›',
              onAction: onExplore,
            ),
            const SizedBox(height: 8),
            _ServicesGrid(onSelected: onExplore),
            const SizedBox(height: 18),
            SectionTitle(
              title: 'Parceiros Perto de Você',
              action: 'Ver todos  ›',
              onAction: () => _showInfo(
                context,
                'Parceiros próximos',
                '2 estabelecimentos parceiros encontrados em São José dos Pinhais.',
              ),
            ),
            const SizedBox(height: 8),
            const _PartnersRow(),
            const SizedBox(height: 14),
            const SectionTitle(title: 'Acessos Rápidos'),
            const SizedBox(height: 8),
            if (canTrack) ...[
              _FeatureBanner(
                icon: Icons.route_rounded,
                iconColor: AppColors.primary,
                title: 'Acompanhar Atendimento',
                subtitle: demoState.bookingStatus.label,
                trailing: const StatusPill(label: 'EM ANDAMENTO'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TripScreen()),
                ),
              ),
              const SizedBox(height: 10),
            ] else
              _FeatureBanner(
                icon: Icons.calendar_month_outlined,
                iconColor: AppColors.purple,
                title: 'Meus Atendimentos',
                subtitle: demoState.bookingStatus.label,
                trailing: const StatusPill(label: 'CLIENTE', color: AppColors.purple),
                onTap: onBookings ?? () {},
              ),
            if (canReview) ...[
              const SizedBox(height: 10),
              _FeatureBanner(
                icon: Icons.star_outline_rounded,
                iconColor: AppColors.purple,
                title: 'Avaliar Atendimento',
                subtitle: 'Nota, destaques e relato da experiência',
                trailing: const StatusPill(label: 'PÓS-SERVIÇO', color: AppColors.purple),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RatingScreen()),
                ),
              ),
            ],
            const SizedBox(height: 10),
            _FeatureBanner(
              icon: Icons.verified_user_outlined,
              iconColor: AppColors.primary,
              title: 'Verificar Identidade',
              subtitle: 'ID Check · Segurança',
              trailing: StatusPill(
                label: demoState.identityVerified ? 'VERIFICADO' : 'PENDENTE',
                color: demoState.identityVerified ? AppColors.green : AppColors.primary,
              ),
              onTap: () {
                if (demoState.identityVerified) {
                  _showInfo(
                    context,
                    'Identidade verificada',
                    'Seu ID Check está concluído e protegido pela REDGLOW.',
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const IdentityVerificationScreen()),
                );
              },
            ),
            const SizedBox(height: 18),
            SectionTitle(
              title: 'Profissionais em Destaque',
              action: 'Ver todos  ›',
              onAction: onExplore,
            ),
            const SizedBox(height: 8),
            ...professionals.map(
              (professional) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: _ProfessionalTile(
                  professional: professional,
                  onTap: () {
                    if (professional.name == 'Lari (Manicure)') {
                      Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const OrderConfirmationScreen(),
                            ),
                          );
                      return;
                    }
                    _showInfo(
                      context,
                      professional.name,
                      '${professional.specialty} · ${professional.rating} estrelas · ${professional.price}. Agenda demonstrativa disponível em breve.',
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            _OfferCard(onTap: onExplore),
          ],
        ),
      ),
    );
  }
}

void _showInfo(BuildContext context, String title, String message) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendi'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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
          child: InkWell(
            onTap: () => _showInfo(
              context,
              'Localização de atendimento',
              'R. Izabel A Redentora, 1000 — Centro, São José dos Pinhais, PR.',
            ),
            borderRadius: BorderRadius.circular(8),
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
        ),
        _HeaderAction(
          icon: Icons.notifications_none_rounded,
          onPressed: () => _showInfo(
            context,
            'Notificações',
            'Nenhuma nova notificação. As atualizações do atendimento aparecerão aqui.',
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _showInfo(
            context,
            'Perfil da cliente',
            'Use a aba Perfil no menu inferior para acessar seus dados e configurações.',
          ),
          customBorder: const CircleBorder(),
          child: const ProfileAvatar(
            imageUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=180',
            size: 38,
          ),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      color: AppColors.textSecondary,
      style: IconButton.styleFrom(
        fixedSize: const Size(36, 36),
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points});

  final int points;

  String get formattedPoints => points.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );

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
                    Text(formattedPoints, style: Theme.of(context).textTheme.headlineMedium),
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
                child: Column(
                  children: [
                    const Text('Próximo', style: TextStyle(fontSize: 8, color: Colors.white70)),
                    const Text('R\$ 25', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    Text(
                      'em ${(3000 - points).clamp(0, 3000)} pts',
                      style: const TextStyle(fontSize: 7, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Expanded(child: Text('Meta: 3.000 pts', style: TextStyle(fontSize: 8))),
              Text(
                '${((points / 3000).clamp(0, 1) * 100).toStringAsFixed(1).replaceAll('.', ',')}%',
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (points / 3000).clamp(0, 1).toDouble(),
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
                  onTap: () {
                    final state = DemoAppScope.of(context, listen: false);
                    final success = state.redeemPoints();
                    final missing = (2500 - state.points).clamp(0, 2500);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Cupom de R\$ 25 resgatado. Confira no histórico.'
                              : 'Você precisa de mais $missing pontos para resgatar.',
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PointsButton(
                  label: 'Ver Histórico',
                  background: Colors.white,
                  foreground: Color(0xFF6C2ED0),
                  onTap: () => _showInfo(
                    context,
                    'Histórico de pontos',
                    '+60 pontos · Avaliação do atendimento\n+25 pontos · Campanha de fim de semana\n+120 pontos · Serviços anteriores',
                  ),
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
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: SizedBox(
          height: 34,
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: foreground, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({this.onSelected});

  final VoidCallback? onSelected;

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
                  child: InkWell(
                    onTap: onSelected,
                    borderRadius: BorderRadius.circular(15),
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
    return SizedBox(
      width: 220,
      child: GlowCard(
        onTap: () => _showInfo(
          context,
          title,
          '$category · $distance de distância · Oferta de $discount disponível.',
        ),
        padding: EdgeInsets.zero,
        radius: AppRadius.md,
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
                  errorBuilder: (_, _, _) => const ColoredBox(
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
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    tooltip: 'Favoritar parceiro',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$title foi adicionado aos favoritos.')),
                    ),
                    icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
                  ),
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
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
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
          ?trailing,
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
  const _OfferCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
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
      ),
    );
  }
}
