import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final notifications = _notificationsFor(state, role);
    return Scaffold(
      body: ConstrainedMobileBody(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notificações',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          'Atualizações importantes em um só lugar',
                          style: TextStyle(fontSize: 9, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const StatusPill(label: 'AO VIVO', color: AppColors.green),
                ],
              ),
              const SizedBox(height: 16),
              for (var index = 0; index < notifications.length; index++) ...[
                _NotificationCard(item: notifications[index]),
                if (index < notifications.length - 1)
                  const SizedBox(height: 9),
              ],
              const SizedBox(height: 12),
              const GlowCard(
                color: Color(0xFF15151D),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notifications_active_outlined, color: AppColors.purple),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nesta etapa, a central mostra eventos sincronizados dentro do aplicativo. Notificações no celular serão ativadas antes do beta externo.',
                        style: TextStyle(fontSize: 9, height: 1.45, color: AppColors.textSecondary),
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

  static List<_NotificationItem> _notificationsFor(
    DemoAppState state,
    UserRole role,
  ) {
    final isProvider = role == UserRole.provider;
    final statusItem = switch (state.bookingStatus) {
      DemoBookingStatus.requested => _NotificationItem(
          icon: isProvider
              ? Icons.notifications_active_rounded
              : Icons.hourglass_top_rounded,
          color: AppColors.primary,
          title: isProvider
              ? 'Nova solicitação recebida'
              : 'Solicitação enviada',
          message: isProvider
              ? '${state.clientName} solicitou Manicure e Pedicure por R\$ 60,00.'
              : 'Aguardando ${state.providerName} aceitar o atendimento.',
          time: 'Agora',
        ),
      DemoBookingStatus.accepted => _NotificationItem(
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.green,
          title: 'Atendimento aceito',
          message: isProvider
              ? 'A cliente foi avisada. Inicie o trajeto quando estiver pronta.'
              : '${state.providerName} aceitou a solicitação.',
          time: 'Agora',
        ),
      DemoBookingStatus.onTheWay => _NotificationItem(
          icon: Icons.route_rounded,
          color: AppColors.route,
          title: 'Trajeto iniciado',
          message: isProvider
              ? 'O deslocamento está sendo acompanhado pela cliente.'
              : '${state.providerName} está a caminho do endereço.',
          time: 'Agora',
        ),
      DemoBookingStatus.inProgress => const _NotificationItem(
          icon: Icons.play_circle_outline_rounded,
          color: AppColors.route,
          title: 'Atendimento em andamento',
          message: 'A Central de Segurança permanece disponível pelo botão SOS.',
          time: 'Agora',
        ),
      DemoBookingStatus.completed => const _NotificationItem(
          icon: Icons.task_alt_rounded,
          color: AppColors.green,
          title: 'Serviço concluído',
          message: 'A avaliação mútua foi liberada.',
          time: 'Agora',
        ),
      DemoBookingStatus.reviewed => const _NotificationItem(
          icon: Icons.star_rounded,
          color: AppColors.yellow,
          title: 'Avaliação registrada',
          message: 'O relato pode ser consultado no histórico do atendimento.',
          time: 'Hoje',
        ),
      DemoBookingStatus.cancelled => const _NotificationItem(
          icon: Icons.event_busy_outlined,
          color: Colors.redAccent,
          title: 'Atendimento cancelado',
          message: 'O cancelamento do beta não gerou cobrança.',
          time: 'Hoje',
        ),
      DemoBookingStatus.idle => _NotificationItem(
          icon: Icons.waving_hand_outlined,
          color: AppColors.primary,
          title: isProvider ? 'Perfil disponível' : 'Bem-vinda ao REDGLOW',
          message: isProvider
              ? 'Fique online para receber novas solicitações.'
              : 'Escolha uma profissional para iniciar o ciclo demonstrativo.',
          time: 'Hoje',
        ),
    };

    return [
      statusItem,
      _NotificationItem(
        icon: Icons.verified_user_outlined,
        color: state.identityVerified ? AppColors.green : AppColors.purple,
        title: state.identityVerified
            ? 'Identidade verificada'
            : 'Verificação de identidade pendente',
        message: state.identityVerified
            ? 'O status de segurança do perfil está atualizado.'
            : 'Conclua a simulação de segurança antes do beta externo.',
        time: 'Perfil',
      ),
      if (isProvider)
        const _NotificationItem(
          icon: Icons.insights_rounded,
          color: AppColors.green,
          title: 'Novo painel de desempenho',
          message: 'Acompanhe ganhos, ticket médio e serviços mais procurados.',
          time: 'Novidade',
        )
      else
        _NotificationItem(
          icon: Icons.workspace_premium_outlined,
          color: AppColors.yellow,
          title: 'Saldo de pontos',
          message: 'Você possui ${state.points} pontos demonstrativos.',
          time: 'Conta',
        ),
    ];
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.time,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String time;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(item.icon, color: item.color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(item.time, style: const TextStyle(fontSize: 7, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(fontSize: 9, height: 1.4, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
