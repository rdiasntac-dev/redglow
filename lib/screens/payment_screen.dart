import 'package:flutter/material.dart';

import '../models/service_catalog.dart';
import '../services/payment_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'order_confirmation_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.serviceName,
    required this.servicePrice,
    required this.providerName,
  });

  final String serviceName;
  final double servicePrice;
  final String providerName;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.pix;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Checkout DEMO'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumo do atendimento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.serviceName),
                    const SizedBox(height: 4),
                    Text(widget.providerName),
                    const SizedBox(height: 4),
                    Text(
                      RedGlowServiceCatalog.formatCurrency(
                        (widget.servicePrice * 100).round(),
                      ),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Método de pagamento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              RadioGroup<PaymentMethod>(
                groupValue: _selectedMethod,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedMethod = value);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final method in PaymentMethod.values)
                      RadioListTile<PaymentMethod>(
                        value: method,
                        activeColor: AppColors.primary,
                        title: Text(method.label),
                        subtitle: Text(method.demoHint),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nenhum dado sensível é coletado aqui. O fluxo real do checkout fica na confirmação do pedido.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              const Spacer(),
              GradientButton(
                label: 'Ir para confirmação',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const OrderConfirmationScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
