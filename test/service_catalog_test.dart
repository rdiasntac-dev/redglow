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
}
