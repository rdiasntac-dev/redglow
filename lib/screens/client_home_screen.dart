import 'dart:async';

import 'package:flutter/material.dart';

import '../models/service_catalog.dart';
import '../models/user_role.dart';
import '../services/firebase_marketplace_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/brand_logo.dart';
import '../widgets/service_selection_sheet.dart';
import 'identity_verification_screen.dart';
import 'notifications_screen.dart';
import 'order_confirmation_screen.dart';
import 'rating_screen.dart';
import 'rewards_screen.dart';
import 'trip_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onExplore,
    this.onBookings,
  });

  final VoidCallback? onExplore;
  final VoidCallback? onBookings;

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final canTrack = {
      DemoBookingStatus.onTheWay,
      DemoBookingStatus.inProgress,
    }.contains(state.bookingStatus);
    final ratingBooking = state.pendingRatings.isNotEmpty
        ? state.pendingRatings.first
        : state.bookingStatus == DemoBookingStatus.completed
            ? state.currentBooking
            : null;
    final canReview =
        state.isDemoSession
            ? state.bookingStatus == DemoBookingStatus.completed
            : ratingBooking != null;

    return ConstrainedMobileBody(
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('home-scroll'),
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 26),
          children: [
            _HomeHeader(state: state),
            if (state.backendError != null) ...[
              const SizedBox(height: 10),
              _ClientSyncAlert(state: state),
            ],
            const SizedBox(height: 14),
            _PointsCard(points: state.points),
            const SizedBox(height: 20),
            SectionTitle(
              title: 'Atendimentos REDGLOW',
              action: 'Ver todos  ›',
              onAction: onExplore,
            ),
            const SizedBox(height: 9),
            _FocusedServicesGrid(onSelected: onExplore),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Parceiros e recompensas'),
            const SizedBox(height: 9),
            const _PartnerCarousel(),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Acessos rápidos'),
            const SizedBox(height: 9),
            if (canTrack)
              _ActionCard(
                icon: Icons.route_rounded,
                color: AppColors.route,
                title: 'Acompanhar atendimento',
                subtitle: state.bookingStatus.label,
                status: 'EM ANDAMENTO',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TripScreen()),
                ),
              )
            else
              _ActionCard(
                icon: Icons.calendar_month_outlined,
                color: AppColors.purple,
                title: 'Meus atendimentos',
                subtitle: state.bookingStatus.label,
                status: 'CLIENTE',
                onTap: onBookings ?? () {},
              ),
            if (canReview) ...[
              const SizedBox(height: 10),
              _ActionCard(
                icon: Icons.star_outline_rounded,
                color: AppColors.yellow,
                title: 'Avaliar atendimento',
                subtitle: 'Conte como foi sua experiência',
                status: 'PÓS-SERVIÇO',
                onTap: () {
                  if (ratingBooking != null) {
                    state.selectBooking(ratingBooking);
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RatingScreen(
                        bookingId: ratingBooking?.id,
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 10),
            _ActionCard(
              key: const Key('identity-check-entry'),
              icon: Icons.verified_user_outlined,
              color: state.identityVerified
                  ? AppColors.green
                  : AppColors.primary,
              title: 'Verificar identidade',
              subtitle: 'Mais confiança para clientes e profissionais',
              status: state.identityVerified ? 'VERIFICADO' : 'PENDENTE',
              onTap: () {
                if (state.identityVerified) {
                  _showInfo(
                    context,
                    'Identidade verificada',
                    'Seu perfil consta como verificado no cadastro REDGLOW.',
                  );
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const IdentityVerificationScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            SectionTitle(
              title: 'Profissionais disponíveis',
              action: 'Buscar  ›',
              onAction: onExplore,
            ),
            const SizedBox(height: 9),
            _AvailableProfessionalCard(state: state),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.state});

  final DemoAppState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const RedGlowBrandMark(size: 34),
        const SizedBox(width: 7),
        Expanded(
          child: InkWell(
            onTap: () async {
              final succeeded = await state.refreshLocation();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    succeeded
                        ? 'Localização atualizada com segurança.'
                        : state.locationSummary,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUA LOCALIZAÇÃO',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.hasCurrentLocation
                      ? 'Local atual confirmado'
                      : 'Permitir localização durante o uso',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  state.locationSummary,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          key: const Key('client-notifications'),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationsScreen(role: UserRole.client),
            ),
          ),
          icon: const Icon(Icons.notifications_none_rounded, size: 20),
          color: AppColors.textSecondary,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        const SizedBox(width: 7),
        ProfileAvatar(
          key: const Key('client-home-avatar'),
          imageUrl: state.profilePhotoUrl,
          fallbackText: state.accountName ?? 'Cliente',
          size: 39,
          borderColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _ClientSyncAlert extends StatelessWidget {
  const _ClientSyncAlert({required this.state});

  final DemoAppState state;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      key: const Key('client-sync-error'),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      borderColor: Colors.redAccent.withValues(alpha: .55),
      color: Colors.redAccent.withValues(alpha: .07),
      child: Row(
        children: [
          const Icon(Icons.sync_problem_rounded, color: Colors.redAccent),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              state.backendError!,
              style: const TextStyle(fontSize: 9, height: 1.35),
            ),
          ),
          IconButton(
            tooltip: 'Fechar aviso',
            onPressed: state.clearBackendError,
            icon: const Icon(Icons.close_rounded, size: 17),
          ),
        ],
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
    const target = DemoAppState.pointsRedemptionCost;
    final progress = (points / target).clamp(0, 1).toDouble();
    return GlowCard(
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 13,
                          color: AppColors.yellow,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'REDGLOW PONTOS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formattedPoints,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Text(
                      'pontos acumulados',
                      style: TextStyle(color: Colors.white70, fontSize: 9),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Próxima troca',
                      style: TextStyle(fontSize: 8, color: Colors.white70),
                    ),
                    Text(
                      '10 pts',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation(AppColors.yellow),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RewardsScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                  ),
                  icon: const Icon(Icons.redeem_rounded, size: 16),
                  label: const Text('Ver recompensas'),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _showInfo(
                    context,
                    'Como ganhar pontos',
                    'Os pontos entram após a conclusão do atendimento. Cancelamentos não pontuam. A reserva do produto ainda é um teste sem entrega ou cobrança real.',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6C2ED0),
                  ),
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text('Como funciona'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusedServicesGrid extends StatelessWidget {
  const _FocusedServicesGrid({this.onSelected});

  final VoidCallback? onSelected;

  static const icons = <String, IconData>{
    'Manicure': Icons.back_hand_outlined,
    'Pedicure': Icons.spa_outlined,
    'Nail Designer': Icons.auto_awesome_rounded,
    'Maquiadora': Icons.brush_outlined,
    'Designer de Sobrancelhas': Icons.face_retouching_natural_outlined,
    'Lash Designer': Icons.visibility_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 12,
          children: RedGlowServiceCatalog.categories
              .map(
                (category) => SizedBox(
                  width: itemWidth,
                  child: InkWell(
                    onTap: onSelected,
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      children: [
                        Container(
                          height: 62,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Center(
                            child: Icon(
                              icons[category.label] ?? Icons.auto_awesome,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          category.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _PartnerCampaign {
  const _PartnerCampaign({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.colors,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> colors;
}

class _PartnerCarousel extends StatefulWidget {
  const _PartnerCarousel();

  @override
  State<_PartnerCarousel> createState() => _PartnerCarouselState();
}

class _PartnerCarouselState extends State<_PartnerCarousel> {
  static const campaigns = [
    _PartnerCampaign(
      eyebrow: 'PROGRAMA DE PARCEIROS',
      title: 'Sua marca dentro do REDGLOW',
      description: 'Espaço rotativo para marcas ligadas a unhas, maquiagem, cílios e sobrancelhas.',
      icon: Icons.campaign_outlined,
      colors: [Color(0xFFC22A9F), Color(0xFF6428A3)],
    ),
    _PartnerCampaign(
      eyebrow: 'REDGLOW PONTOS',
      title: 'Produtos que viram recompensas',
      description: 'Parceiros poderão oferecer itens para troca usando os pontos conquistados pelas clientes.',
      icon: Icons.redeem_rounded,
      colors: [Color(0xFF7B35C8), Color(0xFF3A2B85)],
    ),
    _PartnerCampaign(
      eyebrow: 'BETA SÃO JOSÉ DOS PINHAIS',
      title: 'Vitrine local e segmentada',
      description: 'Campanhas voltadas somente ao público e às profissionais do nicho REDGLOW.',
      icon: Icons.storefront_outlined,
      colors: [Color(0xFFB62E70), Color(0xFF65284F)],
    ),
  ];

  late final PageController _controller;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: .94);
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_page + 1) % campaigns.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 154,
          child: PageView.builder(
            controller: _controller,
            itemCount: campaigns.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (context, index) {
              final campaign = campaigns[index];
              return Padding(
                padding: const EdgeInsets.only(right: 9),
                child: InkWell(
                  onTap: () => _showInfo(
                    context,
                    campaign.title,
                    '${campaign.description}\n\nDurante o beta, estes espaços são institucionais e não representam anunciantes contratados.',
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: campaign.colors),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                campaign.eyebrow,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                campaign.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                campaign.description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white70,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          campaign.icon,
                          size: 68,
                          color: Colors.white.withValues(alpha: .2),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            campaigns.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: index == _page ? 18 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: index == _page
                    ? AppColors.primary
                    : AppColors.textMuted,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: .5)),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusPill(label: status, color: color),
          const SizedBox(width: 5),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _AvailableProfessionalCard extends StatelessWidget {
  const _AvailableProfessionalCard({required this.state});

  final DemoAppState state;

  @override
  Widget build(BuildContext context) {
    final realProfessional = state.selectedProfessional;
    if (!state.isDemoSession && realProfessional == null) {
      return GlowCard(
        borderColor: AppColors.primary.withValues(alpha: .35),
        child: const Row(
          children: [
            Icon(
              Icons.person_search_outlined,
              color: AppColors.primary,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nenhuma profissional disponível agora',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'O beta exibe somente profissionais reais cadastradas e online.',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final name = state.isDemoSession
        ? 'Lari (Manicure)'
        : realProfessional?.name ?? 'Prestadora REDGLOW';
    final specialty = state.isDemoSession
        ? 'Manicure'
        : realProfessional?.specialty ?? state.providerSpecialty;
    final photoUrl = state.isDemoSession
        ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=240'
        : realProfessional?.photoUrl ?? '';
    final startingPriceCents = state.isDemoSession
        ? state.demoProviderServicePricesCents.values.reduce(
            (current, next) => current < next ? current : next,
          )
        : realProfessional?.startingPriceCents ?? state.providerPriceCents;

    return GlowCard(
      onTap: () async {
        final professional = realProfessional ??
            MarketplaceProfessional(
              uid: 'demo-lari',
              name: name,
              specialty: specialty,
              specialties: state.demoProviderSpecialties,
              priceCents: state.demoProviderPriceCents,
              rating: 4.9,
              services: state.demoProviderServices,
              servicePricesCents: state.demoProviderServicePricesCents,
              isOnline: true,
              photoUrl: photoUrl,
            );
        final selected = await showServiceSelectionSheet(
          context,
          professional: professional,
        );
        if (!context.mounted || selected == null) return;
        state.selectProfessional(professional, serviceNames: selected);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrderConfirmationScreen()),
        );
      },
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ProfileAvatar(
            imageUrl: photoUrl,
            size: 55,
            borderColor: AppColors.primary,
            fallbackIcon: Icons.badge_outlined,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  specialty,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  state.isDemoSession
                      ? '★ 4.9 · Perfil demonstrativo'
                      : '${realProfessional?.publicCode ?? state.selectedProviderCode} · perfil real do beta',
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'A partir de',
                style: TextStyle(fontSize: 7, color: AppColors.textMuted),
              ),
              Text(
                RedGlowServiceCatalog.formatCurrency(startingPriceCents),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              const StatusPill(
                label: 'DISPONÍVEL',
                color: AppColors.green,
              ),
            ],
          ),
        ],
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
