import 'package:flutter/material.dart';

import '../models/app_models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  bool _isOnline = true;
  bool _alertSent = false;

  static const appointments = [
    Appointment(
      time: '14:00',
      duration: '1h30min',
      client: 'Amanda Souza',
      service: 'Manicure e Pedicure',
      address: 'R. Izabel A Redentora, 1000',
      price: 'R\$ 60,00',
      imageUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=160',
    ),
    Appointment(
      time: '16:00',
      duration: '45 min',
      client: 'Priscila Matos',
      service: 'Manicure',
      address: 'Av. das Torres, 412 — Centro',
      price: 'R\$ 35,00',
      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=160',
    ),
    Appointment(
      time: '17:30',
      duration: '45 min',
      client: 'Renata Campos',
      service: 'Pedicure',
      address: 'R. Pedro Gusso, 88',
      price: 'R\$ 30,00',
      imageUrl: 'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?w=160',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedMobileBody(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
            children: [
              _ProviderHeader(isOnline: _isOnline),
              const SizedBox(height: 10),
              _OnlineCard(
                isOnline: _isOnline,
                onChanged: (value) => setState(() => _isOnline = value),
              ),
              const SizedBox(height: 12),
              const _EarningsCard(),
              const SizedBox(height: 14),
              const SectionTitle(title: 'Próximos Atendimentos', action: 'Ver agenda  ›'),
              const SizedBox(height: 7),
              for (var i = 0; i < appointments.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: _AppointmentCard(
                    appointment: appointments[i],
                    next: i == 0,
                  ),
                ),
              const SizedBox(height: 4),
              const _MonthlyPerformanceCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          child: GradientButton(
            label: _alertSent
                ? 'Alerta enviado — Toque para cancelar'
                : 'Central de Segurança · Emergência',
            icon: _alertSent ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            gradient: _alertSent
                ? const LinearGradient(colors: [Color(0xFF0FBF8B), Color(0xFF0E9F75)])
                : const LinearGradient(colors: [Color(0xFFFF304D), Color(0xFFE42173)]),
            onPressed: () {
              setState(() => _alertSent = !_alertSent);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _alertSent
                        ? 'Alerta de segurança enviado com sua localização.'
                        : 'Alerta cancelado.',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProviderHeader extends StatelessWidget {
  const _ProviderHeader({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MODO PRESTADORA', style: TextStyle(fontSize: 8, color: AppColors.textSecondary, letterSpacing: .4)),
              Text('Lari (Manicure)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('★ 4.9', style: TextStyle(color: AppColors.yellow, fontSize: 13, fontWeight: FontWeight.w900)),
            Text('834 serviços', style: TextStyle(fontSize: 7, color: AppColors.textMuted)),
          ],
        ),
        const SizedBox(width: 9),
        ProfileAvatar(
          imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=180',
          size: 48,
          borderColor: isOnline ? AppColors.green : AppColors.textMuted,
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      borderColor: isOnline ? AppColors.green.withOpacity(.55) : AppColors.border,
      boxShadow: isOnline
          ? [BoxShadow(color: AppColors.green.withOpacity(.1), blurRadius: 16)]
          : null,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Você está Online' : 'Você está Offline',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isOnline ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                Text(
                  isOnline ? 'Recebendo solicitações de clientes.' : 'Ative para receber novas solicitações.',
                  style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: isOnline,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.green,
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.surfaceRaised,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  const _EarningsCard();

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(13),
      borderColor: AppColors.purple.withOpacity(.45),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF25112E), Color(0xFF3B1249)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined, color: AppColors.purple, size: 17),
              const SizedBox(width: 7),
              Text('GANHOS DE HOJE', style: Theme.of(context).textTheme.labelSmall),
              const Spacer(),
              const Text('Seg, 20 Jul', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Total recebido', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('R\$ 125,00', style: TextStyle(fontSize: 30, height: 1.1, fontWeight: FontWeight.w900)),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: StatusPill(label: '+18%', color: AppColors.green, icon: Icons.trending_up_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: _EarningStat(icon: Icons.event_available_rounded, value: '3', label: 'Atendimentos')),
              SizedBox(width: 7),
              Expanded(child: _EarningStat(icon: Icons.hourglass_top_rounded, value: '1', label: 'Em andamento')),
              SizedBox(width: 7),
              Expanded(child: _EarningStat(icon: Icons.payments_outlined, value: 'R\$ 60', label: 'Pendente')),
            ],
          ),
          const SizedBox(height: 11),
          const Text('SEMANA', style: TextStyle(fontSize: 7, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          const _WeekChart(),
        ],
      ),
    );
  }
}

class _EarningStat extends StatelessWidget {
  const _EarningStat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.035),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 7, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart();

  @override
  Widget build(BuildContext context) {
    const values = [.35, .55, .42, .64, .48, .7, 1.0];
    const days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 30 * values[i],
                      decoration: BoxDecoration(
                        gradient: i == values.length - 1 ? pinkGradient : null,
                        color: i == values.length - 1 ? null : AppColors.purple.withOpacity(.25),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(days[i], style: const TextStyle(fontSize: 7, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, required this.next});

  final Appointment appointment;
  final bool next;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(10),
      borderColor: next ? AppColors.primary.withOpacity(.65) : AppColors.border,
      child: Column(
        children: [
          Row(
            children: [
              StatusPill(label: appointment.time, color: next ? AppColors.primary : AppColors.textSecondary, icon: Icons.schedule_rounded),
              const SizedBox(width: 8),
              Text(appointment.duration, style: const TextStyle(fontSize: 8, color: AppColors.textMuted)),
              const Spacer(),
              if (next) const StatusPill(label: 'PRÓXIMO'),
            ],
          ),
          const Divider(height: 14),
          Row(
            children: [
              ProfileAvatar(
                imageUrl: appointment.imageUrl,
                size: 38,
                borderColor: next ? AppColors.primary : AppColors.purple,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.client, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    Text('✦ ${appointment.service}', style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                    Text(
                      '⌖ ${appointment.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 7, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(appointment.price, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w900)),
                  const Text('Detalhes', style: TextStyle(fontSize: 7, color: AppColors.primary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthlyPerformanceCard extends StatelessWidget {
  const _MonthlyPerformanceCard();

  @override
  Widget build(BuildContext context) {
    return const GlowCard(
      padding: EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        children: [
          Icon(Icons.bar_chart_rounded, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Desempenho do Mês', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                Text('R\$ 1.840,00 em julho', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
