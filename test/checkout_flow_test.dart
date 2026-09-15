import 'package:flutter_test/flutter_test.dart';
import 'package:redglow/services/firebase_marketplace_service.dart';
import 'package:redglow/services/payment_service.dart';
import 'package:redglow/state/demo_app_state.dart';

void main() {
  test('selected services compute price, duration and points correctly', () {
    final state = DemoAppState();
    addTearDown(state.dispose);

    final professional = MarketplaceProfessional(
      uid: 'demo-lari',
      name: 'Lari (Manicure)',
      specialty: 'Manicure',
      specialties: const ['Manicure'],
      priceCents: 6000,
      rating: 4.9,
      services: const ['Manicure tradicional', 'Spa das mãos'],
      servicePricesCents: const {
        'Manicure tradicional': 6000,
        'Spa das mãos': 6500,
      },
      isOnline: true,
    );

    state.selectProfessional(
      professional,
      serviceNames: const ['Manicure tradicional', 'Spa das mãos'],
    );

    expect(
      state.selectedServices,
      const ['Manicure tradicional', 'Spa das mãos'],
    );
    expect(state.selectedPriceCents, 12500);
    expect(state.selectedDurationMinutes, 130);
    expect(state.selectedPointsEarned, 21);
  });

  test('demo booking stores the chosen payment method', () async {
    final state = DemoAppState();
    addTearDown(state.dispose);

    final professional = MarketplaceProfessional(
      uid: 'demo-lari',
      name: 'Lari (Manicure)',
      specialty: 'Manicure',
      specialties: const ['Manicure'],
      priceCents: 6000,
      rating: 4.9,
      services: const ['Manicure tradicional'],
      servicePricesCents: const {'Manicure tradicional': 6000},
      isOnline: true,
    );

    state.selectProfessional(
      professional,
      serviceNames: const ['Manicure tradicional'],
    );

    final requested = await state.requestBooking(paymentMethod: 'Dinheiro');

    expect(requested, isTrue);
    expect(state.currentBooking?.paymentMethod, 'Dinheiro');
    expect(state.currentBooking?.status, 'requested');
  });

  test('mock payment provider authorizes the checkout in demo mode', () async {
    const provider = MockPaymentProvider();
    final authorization = await provider.authorize(
      const PaymentRequest(
        method: PaymentMethod.card,
        amountCents: 12500,
        providerName: 'Lari (Manicure)',
        serviceNames: ['Manicure tradicional', 'Spa das mãos'],
      ),
    );

    expect(authorization.approved, isTrue);
    expect(authorization.simulated, isTrue);
    expect(authorization.summary, contains('Cartão'));
    expect(authorization.summary, contains('Lari (Manicure)'));
  });
}
