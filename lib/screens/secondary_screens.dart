import 'package:flutter/material.dart';

import '../services/firebase_marketplace_service.dart';
import '../services/session_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/account_deletion_action.dart';
import '../widgets/common_widgets.dart';
import '../widgets/cancellation_flow.dart';
import 'identity_verification_screen.dart';
import '../models/user_role.dart';
import 'edit_profile_screen.dart';
import 'order_confirmation_screen.dart';
import 'rating_screen.dart';
import 'reviews_screen.dart';
import 'report_issue_screen.dart';
import 'admin_dashboard_screen.dart';
import 'booking_history_screen.dart';
import 'trip_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();
  String _category = 'Todos';

  static const _professionals = [
    (
      name: 'Lari (Manicure)',
      specialty: 'Unhas',
      price: 'R\$ 60,00',
      image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=240',
      bookable: true,
    ),
    (
      name: 'Fernanda Lima',
      specialty: 'Sobrancelha',
      price: 'R\$ 65,00',
      image: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=240',
      bookable: false,
    ),
    (
      name: 'Juliana Melo',
      specialty: 'Cabelo',
      price: 'R\$ 120,00',
      image: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=240',
      bookable: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final realProfessional = state.selectedProfessional;
    final professionals = realProfessional == null
        ? _professionals
        : [
            (
              name: realProfessional.name,
              specialty: realProfessional.specialty,
              price: _formatMarketplaceCurrency(realProfessional.priceCents),
              image: realProfessional.photoUrl ?? _professionals.first.image,
              bookable: true,
            ),
            ..._professionals.skip(1),
          ];
    final query = _searchController.text.trim().toLowerCase();
    final results = professionals.where((professional) {
      final category = professional.specialty == 'Manicure'
          ? 'Unhas'
          : professional.specialty;
      final matchesCategory = _category == 'Todos' || category == _category;
      final matchesQuery = query.isEmpty ||
          professional.name.toLowerCase().contains(query) ||
          professional.specialty.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return ConstrainedMobileBody(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          children: [
            Text('Explorar serviços', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 5),
            Text(
              state.isDemoSession
                  ? 'Conheça a vitrine demonstrativa perto de você.'
                  : 'Encontre profissionais disponíveis no ambiente beta.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('explore-search'),
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Buscar serviço ou profissional',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final category in const ['Todos', 'Unhas', 'Sobrancelha', 'Cabelo']) ...[
                    ChoiceChip(
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                    const SizedBox(width: 7),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            SectionTitle(title: '${results.length} profissionais encontradas'),
            const SizedBox(height: 8),
            if (results.isEmpty)
              const GlowCard(
                child: Text(
                  'Nenhum resultado para essa busca.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              for (final professional in results)
                GlowCard(
                  key: Key('explore-${professional.specialty.toLowerCase()}'),
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.all(10),
                  onTap: () => _openProfessional(context, professional),
                  child: Row(
                    children: [
                      ProfileAvatar(imageUrl: professional.image, size: 52),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(professional.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                            Text(professional.specialty, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                            Text(
                              state.isDemoSession
                                  ? '★ 4.9 · Perfil demonstrativo'
                                  : 'Perfil beta · verificação não exibida',
                              style: const TextStyle(fontSize: 8, color: AppColors.yellow),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(professional.price, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 5),
                          StatusPill(
                            label: state.isDemoSession ||
                                    (professional.bookable && realProfessional != null)
                                ? 'Disponível'
                                : 'Vitrine',
                            color: state.isDemoSession ||
                                    (professional.bookable && realProfessional != null)
                                ? AppColors.green
                                : AppColors.textMuted,
                          ),
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

  void _openProfessional(
    BuildContext context,
    ({String name, String specialty, String price, String image, bool bookable}) professional,
  ) {
    if (professional.bookable) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OrderConfirmationScreen()),
      );
      return;
    }
    _showInfoSheet(
      context,
      professional.name,
      '${professional.specialty} · ${professional.price}. Esta profissional ainda faz parte somente da vitrine demonstrativa.',
    );
  }
}

String _formatMarketplaceCurrency(int cents) {
  final value = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $value';
}

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final status = state.bookingStatus;
    final selectedBooking = state.currentBooking;
    final openBookings = state.isDemoSession
        ? const <MarketplaceBooking>[]
        : state.bookingHistory
            .where(
              (booking) =>
                  {
                    'requested',
                    'accepted',
                    'onTheWay',
                    'inProgress',
                  }.contains(booking.status) ||
                  booking.status == 'completed' &&
                      booking.clientRating == 0,
            )
            .toList(growable: false);
    final isTracking = {
      DemoBookingStatus.onTheWay,
      DemoBookingStatus.inProgress,
    }.contains(status);

    return ConstrainedMobileBody(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          children: [
            Text('Meus atendimentos', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 5),
            const Text(
              'Acompanhe o pedido e conclua as etapas do ciclo.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 16),
            if (openBookings.length > 1) ...[
              Text(
                'ATIVOS E PENDENTES (${openBookings.length})',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: 8),
              for (final booking in openBookings)
                Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: GlowCard(
                    key: Key('client-booking-${booking.id}'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 10,
                    ),
                    borderColor: selectedBooking?.id == booking.id
                        ? AppColors.primary
                        : AppColors.border,
                    onTap: () => state.selectBooking(booking),
                    child: Row(
                      children: [
                        Icon(
                          booking.status == 'completed'
                              ? Icons.star_outline_rounded
                              : Icons.event_available_outlined,
                          color: booking.status == 'completed'
                              ? AppColors.yellow
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.serviceName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${booking.providerName} · ${_bookingStatusLabel(booking.status)}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          _formatMarketplaceCurrency(booking.priceCents),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 5),
            ],
            GlowCard(
              borderColor: status == DemoBookingStatus.completed
                  ? AppColors.green.withValues(alpha: .5)
                  : AppColors.primary.withValues(alpha: .45),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ProfileAvatar(
                        imageUrl: state.selectedProfessional?.photoUrl ?? '',
                        fallbackText: state.providerName,
                        size: 48,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.providerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                            Text(
                              '${selectedBooking?.serviceName ?? state.selectedService} · '
                              '${_formatMarketplaceCurrency(selectedBooking?.priceCents ?? state.providerPriceCents)}',
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusPill(
                        label: _shortStatus(status),
                        color: _statusColor(status),
                      ),
                    ],
                  ),
                  const Divider(height: 22),
                  _StatusTimeline(current: status),
                  const SizedBox(height: 14),
                  Text(
                    _statusGuidance(
                      status,
                      providerName: state.providerName,
                      isDemo: state.isDemoSession,
                    ),
                    style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                  ),
                  if (status == DemoBookingStatus.cancelled &&
                      state.lastCancellationReason.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.redAccent.withValues(alpha: .25),
                        ),
                      ),
                      child: Text(
                        'Motivo: ${state.lastCancellationReason}\nTaxa simulada: R\$ 0,00 · nenhuma cobrança realizada',
                        style: const TextStyle(
                          fontSize: 8,
                          height: 1.45,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  if ({DemoBookingStatus.idle, DemoBookingStatus.cancelled}.contains(status))
                    GradientButton(
                      key: const Key('booking-start'),
                      label: 'Agendar com ${state.providerName}',
                      icon: Icons.calendar_month_rounded,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OrderConfirmationScreen()),
                      ),
                    )
                  else if (status == DemoBookingStatus.requested)
                    OutlinedButton.icon(
                      key: const Key('booking-cancel'),
                      onPressed: () => showCancellationFlow(
                        context,
                        asProvider: false,
                      ),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Cancelar solicitação'),
                    )
                  else if (status == DemoBookingStatus.accepted)
                    Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Pedido aceito. Aguardando ${state.providerName} iniciar o trajeto.')),
                          ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Atualizar status'),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => showCancellationFlow(
                            context,
                            asProvider: false,
                          ),
                          icon: const Icon(Icons.event_busy_outlined, size: 17),
                          label: const Text('Solicitar cancelamento'),
                        ),
                      ],
                    )
                  else if (isTracking)
                    Column(
                      children: [
                        GradientButton(
                          key: const Key('booking-track'),
                          label: 'Acompanhar atendimento',
                          icon: Icons.route_rounded,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TripScreen()),
                          ),
                        ),
                        if (status == DemoBookingStatus.onTheWay) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => showCancellationFlow(
                              context,
                              asProvider: false,
                            ),
                            icon: const Icon(Icons.event_busy_outlined, size: 17),
                            label: const Text('Solicitar cancelamento'),
                          ),
                        ],
                      ],
                    )
                  else if (status == DemoBookingStatus.completed)
                    GradientButton(
                      key: const Key('booking-review'),
                      label: 'Avaliar atendimento',
                      icon: Icons.star_rounded,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RatingScreen(
                            bookingId: selectedBooking?.id,
                          ),
                        ),
                      ),
                    )
                  else if (status == DemoBookingStatus.reviewed)
                    OutlinedButton.icon(
                      key: const Key('booking-open-reviews'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReviewsScreen(
                            viewingAsProvider: false,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.reviews_outlined),
                      label: const Text('Ver avaliação e relato'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrderConfirmationScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Iniciar novo atendimento'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            GlowCard(
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.purple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.isDemoSession
                          ? 'Para continuar, volte à entrada, abra a demonstração da prestadora e aceite o pedido.'
                          : 'Este atendimento é sincronizado pelo Firebase e aparecerá automaticamente na conta da prestadora.',
                      style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _shortStatus(DemoBookingStatus status) => switch (status) {
        DemoBookingStatus.idle => 'SEM PEDIDO',
        DemoBookingStatus.requested => 'SOLICITADO',
        DemoBookingStatus.accepted => 'ACEITO',
        DemoBookingStatus.onTheWay => 'A CAMINHO',
        DemoBookingStatus.inProgress => 'EM SERVIÇO',
        DemoBookingStatus.completed => 'CONCLUÍDO',
        DemoBookingStatus.reviewed => 'AVALIADO',
        DemoBookingStatus.cancelled => 'CANCELADO',
      };

  static Color _statusColor(DemoBookingStatus status) => switch (status) {
        DemoBookingStatus.completed || DemoBookingStatus.reviewed => AppColors.green,
        DemoBookingStatus.cancelled => Colors.redAccent,
        DemoBookingStatus.accepted || DemoBookingStatus.onTheWay || DemoBookingStatus.inProgress => AppColors.route,
        _ => AppColors.primary,
      };

  static String _statusGuidance(
    DemoBookingStatus status, {
    required String providerName,
    required bool isDemo,
  }) => switch (status) {
        DemoBookingStatus.idle => isDemo
            ? 'Você ainda não iniciou o atendimento demonstrativo.'
            : 'Você ainda não possui um atendimento real.',
        DemoBookingStatus.requested => 'Solicitação enviada. Agora a prestadora precisa aceitar.',
        DemoBookingStatus.accepted => '$providerName aceitou seu pedido e está preparando o deslocamento.',
        DemoBookingStatus.onTheWay => 'Acompanhe a rota e envie apenas mensagens rápidas e seguras.',
        DemoBookingStatus.inProgress => 'O atendimento foi iniciado pela prestadora.',
        DemoBookingStatus.completed => isDemo
            ? 'Serviço concluído. Sua avaliação libera 60 pontos.'
            : 'Serviço concluído. Envie sua avaliação para finalizar.',
        DemoBookingStatus.reviewed => isDemo
            ? 'Avaliação registrada e pontos creditados.'
            : 'Avaliação registrada com segurança.',
        DemoBookingStatus.cancelled => 'Esta solicitação foi cancelada.',
      };
}

String _bookingStatusLabel(String status) => switch (status) {
      'requested' => 'Solicitado',
      'accepted' => 'Aceito',
      'onTheWay' => 'A caminho',
      'inProgress' => 'Em atendimento',
      'completed' => 'Avaliação pendente',
      'reviewed' => 'Avaliado',
      'cancelled' => 'Cancelado',
      _ => status,
    };

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.current});

  final DemoBookingStatus current;

  @override
  Widget build(BuildContext context) {
    final currentIndex = switch (current) {
      DemoBookingStatus.idle || DemoBookingStatus.cancelled => 0,
      DemoBookingStatus.requested => 1,
      DemoBookingStatus.accepted => 2,
      DemoBookingStatus.onTheWay => 3,
      DemoBookingStatus.inProgress => 4,
      DemoBookingStatus.completed || DemoBookingStatus.reviewed => 5,
    };
    const labels = ['Pedido', 'Aceite', 'Trajeto', 'Serviço', 'Fim'];

    return Row(
      children: [
        for (var index = 0; index < labels.length; index++) ...[
          Expanded(
            child: Column(
              children: [
                Icon(
                  index < currentIndex ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 17,
                  color: index < currentIndex ? AppColors.green : AppColors.textMuted,
                ),
                const SizedBox(height: 4),
                Text(labels[index], style: const TextStyle(fontSize: 7, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (index < labels.length - 1)
            Container(
              width: 12,
              height: 1,
              color: index + 1 < currentIndex ? AppColors.green : AppColors.border,
            ),
        ],
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    return ConstrainedMobileBody(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),
            Text('Meu perfil', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            GlowCard(
              child: Row(
                children: [
                  ProfileAvatar(
                    key: const Key('client-profile-avatar'),
                    imageUrl: state.profilePhotoUrl,
                    fallbackText: state.accountName ?? 'Cliente',
                    size: 64,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.accountName ?? 'Cliente REDGLOW',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        if (!state.isDemoSession && state.accountEmail != null)
                          Text(
                            state.accountEmail!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        Text(
                          state.identityVerified ? 'Identidade verificada' : 'Identidade pendente',
                          style: TextStyle(
                            color: state.identityVerified ? AppColors.green : AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _ProfileOption(
              icon: Icons.manage_accounts_outlined,
              label: 'Editar meus dados',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(
                    role: UserRole.client,
                  ),
                ),
              ),
            ),
            _ProfileOption(
              icon: Icons.history_rounded,
              label: 'Histórico de atendimentos',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BookingHistoryScreen(
                    role: UserRole.client,
                  ),
                ),
              ),
            ),
            _ProfileOption(
              icon: Icons.reviews_outlined,
              label: 'Minhas avaliações',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReviewsScreen(
                    viewingAsProvider: false,
                  ),
                ),
              ),
            ),
            _ProfileOption(
              icon: Icons.location_on_outlined,
              label: 'Endereços',
              onTap: () => _showInfoSheet(
                context,
                'Endereço principal',
                'R. Izabel A Redentora, 1000 — Centro, São José dos Pinhais, PR.',
              ),
            ),
            _ProfileOption(
              icon: Icons.payments_outlined,
              label: 'Formas de pagamento',
              onTap: () => _showInfoSheet(
                context,
                'Pagamento no beta',
                'Pix está selecionado apenas como preferência. Nenhuma cobrança ou repasse real é realizado nesta versão.',
              ),
            ),
            _ProfileOption(
              icon: Icons.shield_outlined,
              label: 'Segurança e privacidade',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const IdentityVerificationScreen()),
              ),
            ),
            _ProfileOption(
              icon: Icons.report_outlined,
              label: 'Relatar uma situação',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReportIssueScreen(),
                ),
              ),
            ),
            _ProfileOption(
              icon: Icons.help_outline_rounded,
              label: 'Ajuda',
              onTap: () => _showInfoSheet(
                context,
                'Central de ajuda',
                'Demonstração: suporte por atendimento, segurança e cancelamento serão conectados ao backend.',
              ),
            ),
            if (state.isAdmin)
              _ProfileOption(
                icon: Icons.admin_panel_settings_outlined,
                label: 'Painel administrativo',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminDashboardScreen(),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => endCurrentSession(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: .5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(
                state.isDemoSession ? 'Sair da conta demonstrativa' : 'Sair da conta',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 4),
            const AccountDeletionButton(),
          ],
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

void _showInfoSheet(BuildContext context, String title, String message) {
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
                child: const Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
