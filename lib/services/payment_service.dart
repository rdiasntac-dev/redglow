enum PaymentMethod {
  pix,
  card,
  cash,
}

extension PaymentMethodX on PaymentMethod {
  String get label => switch (this) {
        PaymentMethod.pix => 'Pix',
        PaymentMethod.card => 'Cartão',
        PaymentMethod.cash => 'Dinheiro',
      };

  String get demoHint => switch (this) {
        PaymentMethod.pix => 'Pix demonstrativo sem chave real.',
        PaymentMethod.card => 'Cartão demonstrativo sem armazenar dados sensíveis.',
        PaymentMethod.cash => 'Pagamento em dinheiro confirmado apenas no fluxo DEMO.',
      };
}

class PaymentRequest {
  const PaymentRequest({
    required this.method,
    required this.amountCents,
    required this.providerName,
    required this.serviceNames,
  });

  final PaymentMethod method;
  final int amountCents;
  final String providerName;
  final List<String> serviceNames;
}

class PaymentAuthorization {
  const PaymentAuthorization({
    required this.approved,
    required this.simulated,
    required this.summary,
  });

  final bool approved;
  final bool simulated;
  final String summary;
}

abstract class PaymentProvider {
  Future<PaymentAuthorization> authorize(PaymentRequest request);
}

class MockPaymentProvider implements PaymentProvider {
  const MockPaymentProvider();

  @override
  Future<PaymentAuthorization> authorize(PaymentRequest request) async {
    return PaymentAuthorization(
      approved: true,
      simulated: true,
      summary:
          '${request.method.label} registrado em modo DEMO para ${request.providerName}.',
    );
  }
}
