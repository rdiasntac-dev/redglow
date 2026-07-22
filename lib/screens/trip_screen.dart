import 'package:flutter/material.dart';

import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/gps_map.dart';
import 'rating_screen.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  String? _sentMessage;

  Future<void> _send(String message) async {
    final state = DemoAppScope.of(context, listen: false);
    final succeeded = await state.sendQuickMessage(message);
    if (!mounted) return;
    if (!succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.backendError ?? 'Não foi possível enviar a mensagem.'),
        ),
      );
      return;
    }
    setState(() => _sentMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mensagem enviada: “$message”')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final demoState = DemoAppScope.of(context);
    _sentMessage ??= demoState.lastQuickMessage;
    final inService = demoState.bookingStatus == DemoBookingStatus.inProgress;
    final completed = {
      DemoBookingStatus.completed,
      DemoBookingStatus.reviewed,
    }.contains(demoState.bookingStatus);

    return Scaffold(
      body: ConstrainedMobileBody(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sheetTop = constraints.maxHeight * .56;
            return Stack(
              children: [
                Positioned.fill(
                  bottom: constraints.maxHeight * .3,
                  child: const UrbanGpsMap(
                    showProviderChip: true,
                    showEtaChip: false,
                    compactRoute: true,
                  ),
                ),
                Positioned(
                  left: 14,
                  top: MediaQuery.paddingOf(context).top + 8,
                  child: RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: sheetTop,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      border: Border(top: BorderSide(color: AppColors.border)),
                      boxShadow: [BoxShadow(color: Color(0x77000000), blurRadius: 28, offset: Offset(0, -8))],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const ProfileAvatar(
                                imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=180',
                                size: 47,
                                borderColor: AppColors.green,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      inService
                                          ? 'Atendimento em andamento'
                                          : completed
                                              ? 'Atendimento concluído'
                                              : 'A prestadora está chegando',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      inService
                                          ? '${demoState.providerName} confirmou a chegada'
                                          : completed
                                              ? 'Manicure e Pedicure finalizado'
                                              : '${demoState.providerName} · aproximadamente 5 min',
                                      style: const TextStyle(fontSize: 9, color: AppColors.green),
                                    ),
                                  ],
                                ),
                              ),
                              RoundIconButton(
                                icon: Icons.call_outlined,
                                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Ligação protegida simulada para ${demoState.providerName}.',
                                    ),
                                  ),
                                ),
                                size: 36,
                                color: AppColors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: const LinearProgressIndicator(
                              value: .76,
                              minHeight: 6,
                              backgroundColor: AppColors.surfaceRaised,
                              valueColor: AlwaysStoppedAnimation(AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('AÇÕES RÁPIDAS POR TOQUE', style: Theme.of(context).textTheme.labelSmall),
                          const SizedBox(height: 4),
                          const Text(
                            'Sem chat livre: escolha uma mensagem segura.',
                            style: TextStyle(fontSize: 8, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 10),
                          _QuickMessageButton(
                            label: 'Pode subir/entrar',
                            icon: Icons.door_front_door_outlined,
                            color: AppColors.green,
                            sent: _sentMessage == 'Pode subir/entrar',
                            onTap: () => _send('Pode subir/entrar'),
                          ),
                          const SizedBox(height: 8),
                          _QuickMessageButton(
                            label: 'Estou descendo',
                            icon: Icons.stairs_rounded,
                            color: AppColors.route,
                            sent: _sentMessage == 'Estou descendo',
                            onTap: () => _send('Estou descendo'),
                          ),
                          const SizedBox(height: 8),
                          _QuickMessageButton(
                            label: 'Campainha quebrada',
                            icon: Icons.notifications_off_outlined,
                            color: AppColors.yellow,
                            sent: _sentMessage == 'Campainha quebrada',
                            onTap: () => _send('Campainha quebrada'),
                          ),
                          const SizedBox(height: 12),
                          if (completed)
                            GradientButton(
                              key: const Key('trip-review'),
                              label: 'Avaliar atendimento',
                              icon: Icons.star_rounded,
                              onPressed: () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (_) => const RatingScreen()),
                              ),
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Central de Segurança pronta para acompanhar este atendimento.'),
                                ),
                              ),
                              icon: const Icon(Icons.shield_outlined),
                              label: const Text('Central de Segurança'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickMessageButton extends StatelessWidget {
  const _QuickMessageButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.sent,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool sent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      radius: AppRadius.md,
      borderColor: sent ? color : AppColors.border,
      color: sent ? color.withValues(alpha: .1) : AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: .13), shape: BoxShape.circle),
            child: Icon(sent ? Icons.check_rounded : icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800))),
          Text(sent ? 'Enviado' : 'Enviar', style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
