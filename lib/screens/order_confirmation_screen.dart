import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/gps_map.dart';
import 'trip_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _confirmed = false;

  void _handleConfirm() {
    if (_confirmed) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TripScreen()),
      );
      return;
    }

    setState(() => _confirmed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lari recebeu o chamado e está a caminho.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedMobileBody(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardTop = constraints.maxHeight * .59;
            return Stack(
              children: [
                Positioned.fill(
                  bottom: constraints.maxHeight * .28,
                  child: const UrbanGpsMap(),
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
                  top: cardTop,
                  bottom: 0,
                  child: _OrderSheet(
                    confirmed: _confirmed,
                    onConfirm: _handleConfirm,
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

class _OrderSheet extends StatelessWidget {
  const _OrderSheet({required this.confirmed, required this.onConfirm});

  final bool confirmed;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: Color(0x88000000), blurRadius: 30, offset: Offset(0, -10)),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CONFIRMAR PEDIDO', style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 2),
                      const Text(
                        'Tudo certo para agendar!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withOpacity(.5)),
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const GlowCard(
              padding: EdgeInsets.all(9),
              radius: 14,
              child: Row(
                children: [
                  ProfileAvatar(
                    imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=180',
                    size: 46,
                    borderColor: AppColors.purple,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lari (Manicure)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                        Text('★ 4.9  ·  834 serviços', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                        Text('●  A caminho · ~8 min', style: TextStyle(fontSize: 8, color: AppColors.green)),
                      ],
                    ),
                  ),
                  RoundIconButton(
                    icon: Icons.call_outlined,
                    onPressed: _noop,
                    size: 34,
                    color: AppColors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            const _SummaryCard(),
            const SizedBox(height: 9),
            const _PaymentCard(),
            const SizedBox(height: 10),
            GradientButton(
              label: confirmed ? 'Acompanhar trajeto' : 'Confirmar e Chamar Prestadora',
              icon: confirmed ? Icons.route_rounded : Icons.send_rounded,
              onPressed: onConfirm,
              gradient: confirmed
                  ? const LinearGradient(colors: [Color(0xFF0FBF8B), Color(0xFF0E9F75)])
                  : pinkGradient,
              height: 48,
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Ao confirmar, você concorda com os Termos de Serviço da REDGLOW.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 7, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _noop() {}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(10),
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('RESUMO DO SERVIÇO', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 7),
          const Row(
            children: [
              Icon(Icons.back_hand_rounded, size: 19, color: AppColors.yellow),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manicure e Pedicure', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    Text('Duração estimada: 1h 30min', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text('R\$ 60,00', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 7),
          const Row(
            children: [
              Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'R. Izabel A Redentora, 1000 — Centro, SJP',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(10),
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('FORMA DE PAGAMENTO', style: Theme.of(context).textTheme.labelSmall)),
              const Text('Trocar  ›', style: TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 7),
          const Row(
            children: [
              Icon(Icons.pix_rounded, size: 24, color: AppColors.green),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pix', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    Text('Pagamento instantâneo', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              StatusPill(label: 'Seguro', color: AppColors.green, icon: Icons.shield_outlined),
            ],
          ),
          const Divider(height: 14),
          const Row(
            children: [
              Expanded(child: Text('Total a pagar via Pix', style: TextStyle(fontSize: 9, color: AppColors.textSecondary))),
              Text('R\$ 60,00', style: TextStyle(fontSize: 13, color: AppColors.green, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}
