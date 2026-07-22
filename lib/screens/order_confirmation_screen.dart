import 'package:flutter/material.dart';

import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/emergency_action.dart';
import '../widgets/gps_map.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _confirmed = false;
  String _paymentMethod = 'Pix';

  Future<void> _handleConfirm() async {
    if (_confirmed) {
      Navigator.of(context).pop();
      return;
    }

    final demoState = DemoAppScope.of(context, listen: false);
    if (demoState.hasActiveBooking) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você já possui um atendimento ativo.')),
      );
      return;
    }
    final requested = await demoState.requestBooking(
      paymentMethod: _paymentMethod,
    );
    if (!mounted) return;
    if (!requested) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            demoState.backendError ?? 'Não foi possível enviar a solicitação.',
          ),
        ),
      );
      return;
    }
    setState(() => _confirmed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          demoState.isDemoSession
              ? 'Solicitação enviada. Agora aguarde o aceite de ${demoState.providerName}.'
              : 'Solicitação enviada sem cobrança. Aguarde o aceite de ${demoState.providerName}.',
        ),
      ),
    );
  }

  void _selectPayment() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Forma de pagamento', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              RadioGroup<String>(
                groupValue: _paymentMethod,
                onChanged: (value) {
                    if (value == null) return;
                    setState(() => _paymentMethod = value);
                    Navigator.of(sheetContext).pop();
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final payment in const ['Pix', 'Cartão', 'Dinheiro'])
                      RadioListTile<String>(
                        value: payment,
                        activeColor: AppColors.primary,
                        title: Text(payment),
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

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
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
                    isDemo: state.isDemoSession,
                    paymentMethod: _paymentMethod,
                    providerName: state.providerName,
                    onConfirm: _handleConfirm,
                    onSelectPayment: _selectPayment,
                    onSafety: () => showEmergencyCenter(context),
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
  const _OrderSheet({
    required this.confirmed,
    required this.isDemo,
    required this.paymentMethod,
    required this.providerName,
    required this.onConfirm,
    required this.onSelectPayment,
    required this.onSafety,
  });

  final bool confirmed;
  final bool isDemo;
  final String paymentMethod;
  final String providerName;
  final VoidCallback onConfirm;
  final VoidCallback onSelectPayment;
  final VoidCallback onSafety;

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
                    color: AppColors.primary.withValues(alpha: .1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: .5)),
                  ),
                  child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GlowCard(
              padding: const EdgeInsets.all(9),
              radius: 14,
              child: Row(
                children: [
                  const ProfileAvatar(
                    imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=180',
                    size: 46,
                    borderColor: AppColors.purple,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(providerName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                        Text(
                          isDemo
                              ? '★ 4.9  ·  Perfil demonstrativo'
                              : 'Perfil beta  ·  ID não exibido',
                          style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
                        ),
                        const Text('●  Disponível para o chamado', style: TextStyle(fontSize: 8, color: AppColors.green)),
                      ],
                    ),
                  ),
                  RoundIconButton(
                    icon: Icons.shield_outlined,
                    onPressed: onSafety,
                    size: 34,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            const _SummaryCard(),
            const SizedBox(height: 9),
            _PaymentCard(
              isDemo: isDemo,
              paymentMethod: paymentMethod,
              onSelectPayment: onSelectPayment,
            ),
            const SizedBox(height: 10),
            GradientButton(
              key: const Key('confirm-order'),
              label: confirmed
                  ? 'Fechar e Aguardar Aceite'
                  : isDemo
                      ? 'Confirmar e Chamar Prestadora'
                      : 'Solicitar Atendimento · Sem Cobrança',
              icon: confirmed ? Icons.schedule_rounded : Icons.send_rounded,
              onPressed: onConfirm,
              gradient: confirmed
                  ? const LinearGradient(colors: [Color(0xFF0FBF8B), Color(0xFF0E9F75)])
                  : pinkGradient,
              height: 48,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                isDemo
                    ? 'Fluxo demonstrativo · nenhum pagamento é processado.'
                    : 'Versão beta · a preferência é registrada, mas nenhuma cobrança é realizada.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 7, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  const _PaymentCard({
    required this.isDemo,
    required this.paymentMethod,
    required this.onSelectPayment,
  });

  final bool isDemo;
  final String paymentMethod;
  final VoidCallback onSelectPayment;

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
              Expanded(
                child: Text(
                  'PREFERÊNCIA DE PAGAMENTO · BETA',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
              TextButton(
                onPressed: onSelectPayment,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: const Text('Trocar  ›', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Icon(
                paymentMethod == 'Pix' ? Icons.pix_rounded : Icons.payments_outlined,
                size: 24,
                color: AppColors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(paymentMethod, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    Text(
                      isDemo
                          ? 'Simulação de pagamento'
                          : 'Cobrança ainda não habilitada',
                      style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const StatusPill(
                label: 'SEM COBRANÇA',
                color: AppColors.yellow,
                icon: Icons.science_outlined,
              ),
            ],
          ),
          const Divider(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Valor demonstrativo via $paymentMethod',
                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                ),
              ),
              const Text('R\$ 60,00', style: TextStyle(fontSize: 13, color: AppColors.green, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }
}
