import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/service_catalog.dart';
import '../models/user_role.dart';
import '../services/session_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/account_deletion_action.dart';
import '../widgets/cancellation_flow.dart';
import '../widgets/common_widgets.dart';
import '../widgets/emergency_action.dart';
import 'booking_history_screen.dart';
import 'edit_profile_screen.dart';
import 'identity_verification_screen.dart';
import 'notifications_screen.dart';
import 'provider_analytics_screen.dart';
import 'provider_services_screen.dart';
import 'rating_screen.dart';
import 'report_issue_screen.dart';
import 'reviews_screen.dart';
import 'subscription_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  bool _demoOnline = true;

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final isOnline = state.isDemoSession ? _demoOnline : state.providerOnline;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Para encerrar com segurança, use “Sair da conta”.'),
          ),
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: ConstrainedMobileBody(
                child: SafeArea(
                  bottom: false,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 100),
                    children: [
                      _Header(
                        name: state.accountName ?? 'Profissional REDGLOW',
                        onNotifications: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NotificationsScreen(
                              role: UserRole.provider,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _OnlineCard(
                        isOnline: isOnline,
                        onChanged: (value) {
                          if (state.isDemoSession) {
                            setState(() => _demoOnline = value);
                          } else {
                            state.setProviderOnline(value);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _ProviderProfileStatus(state: state),
                      const SizedBox(height: 12),
                      _BookingStatusCard(state: state, isOnline: isOnline),
                      const SizedBox(height: 12),
                      _SingleDashboardCard(state: state),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ShortcutCard(
                              icon: Icons.verified_user_outlined,
                              title: 'ID profissional',
                              subtitle: state.identityVerified
                                  ? 'Verificado'
                                  : 'Pendente',
                              color: state.identityVerified
                                  ? AppColors.green
                                  : AppColors.primary,
                              onTap: () {
                                if (state.identityVerified) {
                                  _showInfo(
                                    context,
                                    'Identidade verificada',
                                    'Seu perfil está marcado como verificado nesta sessão.',
                                  );
                                  return;
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const IdentityVerificationScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ShortcutCard(
                              icon: Icons.workspace_premium_outlined,
                              title: 'Plano profissional',
                              subtitle: state.professionalPlanActive
                                  ? 'Ativo'
                                  : 'Conhecer plano',
                              color: state.professionalPlanActive
                                  ? AppColors.green
                                  : AppColors.purple,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SubscriptionScreen(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _MenuCard(
                        icon: Icons.manage_accounts_outlined,
                        color: AppColors.primary,
                        title: 'Editar dados profissionais',
                        subtitle: 'Nome, telefone, nicho principal e valor base',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EditProfileScreen(
                              role: UserRole.provider,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      _MenuCard(
                        icon: Icons.reviews_outlined,
                        color: AppColors.purple,
                        title: 'Avaliações e relatos',
                        subtitle: 'Acompanhe o retorno dos atendimentos',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ReviewsScreen(
                              viewingAsProvider: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      _MenuCard(
                        icon: Icons.report_outlined,
                        color: AppColors.yellow,
                        title: 'Relatar uma situação',
                        subtitle: 'Conduta, segurança ou problema técnico',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ReportIssueScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        key: const Key('provider-logout'),
                        onPressed: () => endCurrentSession(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: .5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 18),
                        label: Text(
                          state.isDemoSession
                              ? 'Sair da conta demonstrativa'
                              : 'Sair da conta',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const AccountDeletionButton(),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              right: 14,
              bottom: 14,
              child: EmergencyFloatingButton(
                key: Key('provider-emergency-action'),
                heroTag: 'provider-emergency',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.onNotifications});

  final String name;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PAINEL PROFISSIONAL',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotifications,
          icon: const Icon(Icons.notifications_none_rounded),
          color: AppColors.textSecondary,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.border),
          ),
        ),
      ],
    );
  }
}

class _OnlineCard extends StatelessWidget {
  const _OnlineCard({required this.isOnline, required this.onChanged});

  final bool isOnline;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      borderColor: isOnline
          ? AppColors.green.withValues(alpha: .45)
          : AppColors.border,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isOnline ? AppColors.green : AppColors.textMuted)
                  .withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline ? Icons.wifi_tethering_rounded : Icons.pause_rounded,
              color: isOnline ? AppColors.green : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Disponível para receber pedidos' : 'Pausada',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  isOnline
                      ? 'Seu perfil pode aparecer na busca da cliente.'
                      : 'Você não aparecerá como disponível.',
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: isOnline, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ProviderProfileStatus extends StatelessWidget {
  const _ProviderProfileStatus({required this.state});

  final DemoAppState state;

  @override
  Widget build(BuildContext context) {
    if (state.isDemoSession) {
      final category = RedGlowServiceCatalog.byLabel(state.providerSpecialty);
      return _ServicesProfileCard(
        category: category.label,
        services: state.demoProviderServices,
        demo: true,
      );
    }

    if (Firebase.apps.isEmpty || FirebaseAuth.instance.currentUser == null) {
      return const _ServicesProfileCard(
        category: 'Perfil indisponível',
        services: [],
        demo: false,
      );
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('professionals')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? const <String, dynamic>{};
        final category = RedGlowServiceCatalog.normalizeLabel(
          data['specialty'] as String?,
        );
        final rawServices = data['services'];
        final services = rawServices is List
            ? rawServices.whereType<String>().toList(growable: false)
            : const <String>[];
        return _ServicesProfileCard(
          category: category,
          services: services,
          demo: false,
        );
      },
    );
  }
}

class _ServicesProfileCard extends StatelessWidget {
  const _ServicesProfileCard({
    required this.category,
    required this.services,
    required this.demo,
  });

  final String category;
  final List<String> services;
  final bool demo;

  @override
  Widget build(BuildContext context) {
    final incomplete = services.isEmpty;
    return GlowCard(
      key: const Key('provider-services-profile'),
      borderColor: incomplete
          ? AppColors.yellow.withValues(alpha: .55)
          : AppColors.primary.withValues(alpha: .45),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProviderServicesScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                incomplete
                    ? Icons.playlist_add_check_circle_outlined
                    : Icons.design_services_outlined,
                color: incomplete ? AppColors.yellow : AppColors.primary,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incomplete
                          ? 'Complete os serviços que você realiza'
                          : '$category · ${services.length} serviço(s)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      incomplete
                          ? 'A cliente precisa saber exatamente o que pode contratar.'
                          : services.take(3).join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusPill(
                label: demo
                    ? 'DEMO'
                    : incomplete
                        ? 'PENDENTE'
                        : 'ATUALIZADO',
                color: demo
                    ? AppColors.purple
                    : incomplete
                        ? AppColors.yellow
                        : AppColors.green,
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingStatusCard extends StatelessWidget {
  const _BookingStatusCard({required this.state, required this.isOnline});

  final DemoAppState state;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final status = state.bookingStatus;
    final booking = state.currentBooking;
    final hasRealBooking = state.isDemoSession || booking != null;

    return GlowCard(
      key: const Key('provider-request-card'),
      borderColor: status == DemoBookingStatus.requested
          ? AppColors.primary.withValues(alpha: .65)
          : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status == DemoBookingStatus.requested
                    ? Icons.notifications_active_outlined
                    : Icons.assignment_outlined,
                color: status == DemoBookingStatus.requested
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _bookingTitle(status, hasRealBooking),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              StatusPill(
                label: _bookingPill(status),
                color: _bookingColor(status),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _bookingDescription(state, hasRealBooking, isOnline),
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (hasRealBooking && status != DemoBookingStatus.idle) ...[
            const Divider(height: 20),
            Text(
              '${state.clientName} · ${booking?.serviceName ?? state.providerSpecialty}\n'
              '${booking == null ? RedGlowServiceCatalog.formatCurrency(state.providerPriceCents) : RedGlowServiceCatalog.formatCurrency(booking.priceCents)}',
              style: const TextStyle(fontSize: 9, height: 1.5),
            ),
          ],
          if (status == DemoBookingStatus.cancelled &&
              state.lastCancellationReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Motivo: ${state.lastCancellationReason} · nenhuma cobrança realizada',
              style: const TextStyle(fontSize: 8, color: Colors.redAccent),
            ),
          ],
          const SizedBox(height: 12),
          _BookingAction(state: state, isOnline: isOnline),
        ],
      ),
    );
  }
}

class _BookingAction extends StatelessWidget {
  const _BookingAction({required this.state, required this.isOnline});

  final DemoAppState state;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    switch (state.bookingStatus) {
      case DemoBookingStatus.requested:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => showCancellationFlow(
                  context,
                  asProvider: true,
                ),
                child: const Text('Recusar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: state.acceptBooking,
                child: const Text('Aceitar'),
              ),
            ),
          ],
        );
      case DemoBookingStatus.accepted:
        return Column(
          children: [
            GradientButton(
              label: 'Iniciar deslocamento',
              icon: Icons.route_rounded,
              onPressed: state.startTrip,
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => showCancellationFlow(
                context,
                asProvider: true,
              ),
              child: const Text('Cancelar atendimento'),
            ),
          ],
        );
      case DemoBookingStatus.onTheWay:
        return GradientButton(
          label: 'Iniciar atendimento',
          icon: Icons.play_arrow_rounded,
          onPressed: state.startService,
        );
      case DemoBookingStatus.inProgress:
        return GradientButton(
          label: 'Concluir atendimento',
          icon: Icons.check_circle_outline_rounded,
          onPressed: state.completeService,
          gradient: const LinearGradient(
            colors: [Color(0xFF0FBF8B), Color(0xFF0E9F75)],
          ),
        );
      case DemoBookingStatus.completed:
      case DemoBookingStatus.reviewed:
        return OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const RatingScreen(reviewingClient: true),
            ),
          ),
          icon: const Icon(Icons.star_outline_rounded),
          label: const Text('Avaliar cliente'),
        );
      case DemoBookingStatus.cancelled:
      case DemoBookingStatus.idle:
        return OutlinedButton.icon(
          onPressed: isOnline
              ? () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Você está disponível. Novos pedidos reais aparecerão aqui.',
                      ),
                    ),
                  )
              : null,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(isOnline ? 'Aguardar novos pedidos' : 'Ative sua disponibilidade'),
        );
    }
  }
}

class _SingleDashboardCard extends StatelessWidget {
  const _SingleDashboardCard({required this.state});

  final DemoAppState state;

  @override
  Widget build(BuildContext context) {
    final realBookings = state.isDemoSession ? 0 : state.bookingHistory.length;
    final completed = state.isDemoSession
        ? 0
        : state.bookingHistory
            .where((booking) =>
                booking.status == 'completed' || booking.status == 'reviewed')
            .length;

    return GlowCard(
      key: const Key('provider-main-dashboard'),
      borderColor: AppColors.purple.withValues(alpha: .45),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ProviderAnalyticsScreen()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights_outlined,
                color: AppColors.purple,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Painel de atendimentos',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Uma única entrada para visão mensal e desempenho',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  value: state.isDemoSession ? 'DEMO' : '$realBookings',
                  label: 'Registros',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  value: state.isDemoSession ? '—' : '$completed',
                  label: 'Concluídos',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Metric(
                  value: state.isDemoSession ? '—' : '${state.clientToProviderRating}/5',
                  label: 'Nota atual',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BookingHistoryScreen(
                    role: UserRole.provider,
                  ),
                ),
              ),
              icon: const Icon(Icons.history_rounded, size: 17),
              label: const Text('Ver histórico real de atendimentos'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 7, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 9),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

String _bookingTitle(DemoBookingStatus status, bool hasBooking) {
  if (!hasBooking && status == DemoBookingStatus.idle) {
    return 'Nenhum atendimento real agendado';
  }
  return switch (status) {
    DemoBookingStatus.idle => 'Nenhum atendimento ativo',
    DemoBookingStatus.requested => 'Novo pedido recebido',
    DemoBookingStatus.accepted => 'Atendimento aceito',
    DemoBookingStatus.onTheWay => 'Você está a caminho',
    DemoBookingStatus.inProgress => 'Atendimento em andamento',
    DemoBookingStatus.completed => 'Atendimento concluído',
    DemoBookingStatus.reviewed => 'Atendimento avaliado',
    DemoBookingStatus.cancelled => 'Atendimento cancelado',
  };
}

String _bookingDescription(
  DemoAppState state,
  bool hasBooking,
  bool isOnline,
) {
  if (!hasBooking && !state.isDemoSession) {
    return isOnline
        ? 'Quando uma cliente real solicitar seu atendimento, o pedido aparecerá neste cartão.'
        : 'Ative sua disponibilidade para aparecer na busca das clientes.';
  }
  return switch (state.bookingStatus) {
    DemoBookingStatus.idle => state.isDemoSession
        ? 'Use a demonstração de cliente para criar um pedido de teste.'
        : 'Nenhum pedido real no momento.',
    DemoBookingStatus.requested => 'Confira os dados e escolha aceitar ou recusar.',
    DemoBookingStatus.accepted => 'Inicie o deslocamento quando estiver pronta.',
    DemoBookingStatus.onTheWay => 'Ao chegar, inicie o atendimento.',
    DemoBookingStatus.inProgress => 'Conclua somente depois de finalizar o serviço.',
    DemoBookingStatus.completed => 'O serviço foi concluído e pode ser avaliado.',
    DemoBookingStatus.reviewed => 'O ciclo deste atendimento foi encerrado.',
    DemoBookingStatus.cancelled => 'O motivo do cancelamento fica registrado no histórico.',
  };
}

String _bookingPill(DemoBookingStatus status) => switch (status) {
      DemoBookingStatus.idle => 'AGUARDANDO',
      DemoBookingStatus.requested => 'NOVO',
      DemoBookingStatus.accepted => 'ACEITO',
      DemoBookingStatus.onTheWay => 'A CAMINHO',
      DemoBookingStatus.inProgress => 'EM SERVIÇO',
      DemoBookingStatus.completed => 'CONCLUÍDO',
      DemoBookingStatus.reviewed => 'AVALIADO',
      DemoBookingStatus.cancelled => 'CANCELADO',
    };

Color _bookingColor(DemoBookingStatus status) => switch (status) {
      DemoBookingStatus.idle => AppColors.textMuted,
      DemoBookingStatus.requested => AppColors.primary,
      DemoBookingStatus.accepted => AppColors.purple,
      DemoBookingStatus.onTheWay => AppColors.route,
      DemoBookingStatus.inProgress => AppColors.yellow,
      DemoBookingStatus.completed || DemoBookingStatus.reviewed =>
        AppColors.green,
      DemoBookingStatus.cancelled => Colors.redAccent,
    };

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
            Text(message),
          ],
        ),
      ),
    ),
  );
}
