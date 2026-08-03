import 'package:flutter_test/flutter_test.dart';
import 'package:redglow/models/service_catalog.dart';
import 'package:redglow/services/firebase_marketplace_service.dart';
import 'package:redglow/state/demo_app_state.dart';

MarketplaceBooking _booking({
  required String id,
  required String status,
  int schemaVersion = 2,
  DateTime? completedAt,
  int clientRating = 0,
}) {
  final now = DateTime(2026, 8, 3, 12);
  return MarketplaceBooking(
    id: id,
    clientId: 'client',
    providerId: 'provider',
    clientName: 'Cliente',
    providerName: 'Prestadora',
    status: status,
    serviceName: 'Manicure tradicional',
    serviceNames: const ['Manicure tradicional'],
    priceCents: 6000,
    pointsEarned: 10,
    address: 'São José dos Pinhais',
    paymentMethod: 'Pix',
    createdAt: now,
    updatedAt: now,
    clientRating: clientRating,
    providerRating: 0,
    cancellationReason: '',
    cancelledBy: '',
    simulatedFeeCents: 0,
    schemaVersion: schemaVersion,
    completedAt: completedAt,
  );
}

void main() {
  test('REDGLOW beta exposes only the six approved niches', () {
    expect(
      RedGlowServiceCatalog.labels,
      const [
        'Manicure',
        'Pedicure',
        'Nail Designer',
        'Maquiadora',
        'Designer de Sobrancelhas',
        'Lash Designer',
      ],
    );
  });

  test('unknown legacy specialties are normalized to Manicure', () {
    expect(RedGlowServiceCatalog.normalizeLabel('Cabeleireira'), 'Manicure');
  });

  test('every niche includes a displacement reserve', () {
    for (final category in RedGlowServiceCatalog.categories) {
      expect(category.travelReserveCents, greaterThan(0));
      expect(
        category.recommendedHomeCents,
        greaterThan(category.localMarketCents),
      );
      expect(category.minimumHomeCents, greaterThanOrEqualTo(4000));
    }
  });

  test('a service resolves to its correct niche', () {
    expect(
      RedGlowServiceCatalog.byServiceOrLabel('Alongamento em gel').label,
      'Nail Designer',
    );
    expect(
      RedGlowServiceCatalog.byServiceOrLabel('Spa dos pés').label,
      'Pedicure',
    );
  });

  test('services cannot cross professional niches', () {
    expect(
      RedGlowServiceCatalog.isServiceAllowedForCategory(
        'Manicure',
        'Spa das mãos',
      ),
      isTrue,
    );
    expect(
      RedGlowServiceCatalog.isServiceAllowedForCategory(
        'Manicure',
        'Maquiagem social',
      ),
      isFalse,
    );
  });

  test('each service has its own minimum, quote, duration and points', () {
    expect(
      RedGlowServiceCatalog.referencePriceCents('Manicure tradicional'),
      6000,
    );
    expect(
      RedGlowServiceCatalog.referencePriceCents('Esmaltação em gel'),
      7500,
    );
    expect(
      RedGlowServiceCatalog.minimumPriceCents('Manicure tradicional'),
      lessThanOrEqualTo(6000),
    );
    expect(
      RedGlowServiceCatalog.estimatedMinutesForService(
        'Manicure tradicional',
      ),
      60,
    );
    expect(
      RedGlowServiceCatalog.pointsForService('Manicure tradicional'),
      10,
    );
  });

  test('combined services add their individual prices', () {
    final prices = RedGlowServiceCatalog.defaultPricesForServices(const [
      'Manicure tradicional',
      'Spa das mãos',
    ]);
    expect(
      RedGlowServiceCatalog.totalPriceCents(
        const ['Manicure tradicional', 'Spa das mãos'],
        prices,
      ),
      12500,
    );
  });

  test('price input accepts Brazilian and Android decimal separators', () {
    expect(RedGlowServiceCatalog.parseCurrencyInputToCents('60'), 6000);
    expect(RedGlowServiceCatalog.parseCurrencyInputToCents('60,00'), 6000);
    expect(RedGlowServiceCatalog.parseCurrencyInputToCents('60.00'), 6000);
    expect(
      RedGlowServiceCatalog.parseCurrencyInputToCents('R\$ 1.200,50'),
      120050,
    );
  });

  test('public provider code is stable and never exposes the complete uid', () {
    const uid = 'fQ9px73kLmN2vR8sT1uW4yZ6';

    expect(redGlowPublicCode(uid), 'RG-UW4YZ6');
    expect(redGlowPublicCode(uid), isNot(contains(uid)));
  });

  test('provider presence expires and profiles without heartbeat stay hidden',
      () {
    final now = DateTime(2026, 8, 3, 12);

    expect(
      MarketplaceProfessional.hasFreshAvailability(
        now.subtract(const Duration(minutes: 5)),
        now: now,
      ),
      isTrue,
    );
    expect(
      MarketplaceProfessional.hasFreshAvailability(
        now.subtract(const Duration(minutes: 21)),
        now: now,
      ),
      isFalse,
    );
    expect(
      MarketplaceProfessional.hasFreshAvailability(null, now: now),
      isFalse,
    );
  });

  test('only audited completion earns points', () {
    final completedAt = DateTime(2026, 8, 3, 13);
    final bookings = [
      _booking(
        id: 'valid',
        status: 'completed',
        completedAt: completedAt,
      ),
      _booking(id: 'requested', status: 'requested'),
      _booking(id: 'cancelled', status: 'cancelled'),
      _booking(
        id: 'legacy',
        status: 'completed',
        schemaVersion: 1,
        completedAt: completedAt,
      ),
    ];

    expect(DemoAppState.auditedPointsForBookings(bookings), 10);
    expect(bookings.first.isRatingEligible, isTrue);
    expect(bookings.last.isRatingEligible, isFalse);
  });

  test('legacy completion never becomes a pending rating', () {
    final state = DemoAppState()
      ..isDemoSession = false
      ..bookingHistory = [
        _booking(
          id: 'old-lari',
          status: 'completed',
          schemaVersion: 1,
          completedAt: DateTime(2026, 7, 20),
        ),
      ];
    addTearDown(state.dispose);

    expect(state.pendingRatings, isEmpty);
    expect(state.ignoredLegacyPoints, 10);
  });
}
