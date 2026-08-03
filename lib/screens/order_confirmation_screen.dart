import 'package:flutter/material.dart';

import '../models/service_catalog.dart';
import '../services/device_location_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/emergency_action.dart';
import '../widgets/gps_map.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  bool _confirmed = false;
  String _paymentMethod = 'Pix';

  Future<void> _handleConfirm() async {
    if (_confirmed) {
      Navigator.of(context).pop();
      return;
    }

    final state = DemoAppScope.of(context, listen: false);
    final requested = await state.requestBooking(
      paymentMethod: _paymentMethod,
    );
    if (!mounted) return;
    if (!requested) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.backendError ?? 'Não foi possível enviar a solicitação.',
          ),
        ),
      );
      return;
    }
    setState(() => _confirmed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.isDemoSession
              ? 'Solicitação demonstrativa enviada. Aguarde o aceite de ${state.providerName}.'
              : 'Solicitação enviada sem cobrança. Aguarde o aceite de ${state.providerName}.',
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
              Text(
                'Preferência de pagamento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                'O beta registra apenas a preferência. Nenhum pagamento é processado.',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.textSecondary,
                ),
              ),
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
    final professional = state.selectedProfessional;
    final photoUrl = state.isDemoSession
        ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=180'
        : professional?.photoUrl ?? '';
    final etaMinutes = DeviceLocationService.estimateTravelMinutes(
      fromLatitude: professional?.latitude,
      fromLongitude: professional?.longitude,
      toLatitude: state.accountLatitude,
      toLongitude: state.accountLongitude,
    );
    return Scaffold(
      body: ConstrainedMobileBody(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardTop = constraints.maxHeight * .55;
            return Stack(
              children: [
                Positioned.fill(
                  bottom: constraints.maxHeight * .31,
                  child: UrbanGpsMap(
                    providerName: state.providerName,
                    providerPhotoUrl: photoUrl,
                    etaMinutes: etaMinutes,
                    liveLocation: professional?.latitude != null,
                    providerLatitude: professional?.latitude,
                    providerLongitude: professional?.longitude,
                    destinationLatitude: state.accountLatitude,
                    destinationLongitude: state.accountLongitude,
                    destinationLabel: state.accountAddress ?? 'Destino da cliente',
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
                  top: cardTop,
                  bottom: 0,
                  child: _OrderSheet(
                    confirmed: _confirmed,
                    isDemo: state.isDemoSession,
                    paymentMethod: _paymentMethod,
                    providerName: state.providerName,
                    providerCode: state.selectedProviderCode,
                    providerSpecialty: state.providerSpecialty,
                    serviceNames: state.selectedServices,
                    providerPriceCents: state.selectedPriceCents,
                    durationMinutes: state.selectedDurationMinutes,
                    pointsEarned: state.selectedPointsEarned,
                    providerPhotoUrl: photoUrl,
                    address: state.locationSummary,
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
    required this.providerCode,
    required this.providerSpecialty,
    required this.serviceNames,
    required this.providerPriceCents,
    required this.durationMinutes,
    required this.pointsEarned,
    required this.providerPhotoUrl,
    required this.address,
    required this.onConfirm,
    required this.onSelectPayment,
    required this.onSafety,
  });

  final bool confirmed;
  final bool isDemo;
  final String paymentMethod;
  final String providerName;
  final String providerCode;
  final String providerSpecialty;
  final List<String> serviceNames;
  final int providerPriceCents;
  final int durationMinutes;
  final int pointsEarned;
  final String providerPhotoUrl;
  final String address;
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
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
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
                      Text(
                        'CONFIRMAR PEDIDO',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tudo certo para agendar!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusPill(
                  label: 'BETA · SEM COBRANÇA',
                  color: AppColors.yellow,
                  icon: Icons.science_outlined,
                ),
              ],
            ),
            const SizedBox(height: 10),
            GlowCard(
              padding: const EdgeInsets.all(9),
              radius: 14,
              child: Row(
                children: [
                  ProfileAvatar(
                    imageUrl: providerPhotoUrl,
                    size: 46,
                    borderColor: AppColors.purple,
                    fallbackIcon: Icons.badge_outlined,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          providerName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '$providerSpecialty · $providerCode · ${isDemo ? 'perfil demonstrativo' : 'perfil real'}',
                          style: const TextStyle(
                            fontSize: 8,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Text(
                          '● Disponível para o chamado',
                          style: TextStyle(
                            fontSize: 8,
                            color: AppColors.green,
                          ),
                        ),
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
            _SummaryCard(
              serviceNames: serviceNames,
              priceCents: providerPriceCents,
              durationMinutes: durationMinutes,
              pointsEarned: pointsEarned,
              address: address,
            ),
            const SizedBox(height: 9),
            _PaymentCard(
              paymentMethod: paymentMethod,
              priceCents: providerPriceCents,
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
                  ? const LinearGradient(
                      colors: [Color(0xFF0FBF8B), Color(0xFF0E9F75)],
                    )
                  : pinkGradient,
              height: 48,
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                isDemo
                    ? 'Fluxo demonstrativo · nenhum pagamento é processado.'
                    : 'Versão beta · o valor acompanha o cadastro real da profissional, sem cobrança no aplicativo.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 7,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.serviceNames,
    required this.priceCents,
    required this.durationMinutes,
    required this.pointsEarned,
    required this.address,
  });

  final List<String> serviceNames;
  final int priceCents;
  final int durationMinutes;
  final int pointsEarned;
  final String address;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(10),
      radius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMO DO ATENDIMENTO',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 19,
                color: AppColors.yellow,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final service in serviceNames)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          service,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    Text(
                      'Duração estimada: $durationMinutes min · +$pointsEarned pontos após concluir',
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                RedGlowServiceCatalog.formatCurrency(priceCents),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  address,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.textMuted,
                  ),
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
    required this.paymentMethod,
    required this.priceCents,
    required this.onSelectPayment,
  });

  final String paymentMethod;
  final int priceCents;
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
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  'Trocar  ›',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(
                paymentMethod == 'Pix'
                    ? Icons.pix_rounded
                    : Icons.payments_outlined,
                size: 24,
                color: AppColors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paymentMethod,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'Cobrança ainda não habilitada',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                RedGlowServiceCatalog.formatCurrency(priceCents),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.green,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
