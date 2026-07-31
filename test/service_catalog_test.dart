import 'package:flutter_test/flutter_test.dart';
import 'package:redglow/models/service_catalog.dart';

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
}
