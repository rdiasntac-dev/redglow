class RedGlowServiceCategory {
  const RedGlowServiceCategory({
    required this.id,
    required this.label,
    required this.localMarketCents,
    required this.travelReserveCents,
    required this.minimumHomeCents,
    required this.estimatedMinutes,
    required this.services,
  });

  final String id;
  final String label;
  final int localMarketCents;
  final int travelReserveCents;
  final int minimumHomeCents;
  final int estimatedMinutes;
  final List<String> services;

  int get recommendedHomeCents => localMarketCents + travelReserveCents;
}

/// Catálogo inicial e fechado do REDGLOW para o beta de São José dos Pinhais.
///
/// Os valores são referências de atendimento domiciliar, não preços obrigatórios.
/// A reserva de deslocamento evita que a profissional use como base apenas o valor
/// praticado dentro de um estúdio e acabe absorvendo transporte e tempo de trajeto.
abstract final class RedGlowServiceCatalog {
  static const categories = <RedGlowServiceCategory>[
    RedGlowServiceCategory(
      id: 'manicure',
      label: 'Manicure',
      localMarketCents: 3000,
      travelReserveCents: 1500,
      minimumHomeCents: 4000,
      estimatedMinutes: 60,
      services: [
        'Manicure tradicional',
        'Esmaltação em gel',
        'Spa das mãos',
        'Remoção de esmaltação em gel',
      ],
    ),
    RedGlowServiceCategory(
      id: 'pedicure',
      label: 'Pedicure',
      localMarketCents: 4000,
      travelReserveCents: 1500,
      minimumHomeCents: 5000,
      estimatedMinutes: 75,
      services: [
        'Pedicure tradicional',
        'Esmaltação em gel nos pés',
        'Spa dos pés',
        'Manicure e pedicure',
      ],
    ),
    RedGlowServiceCategory(
      id: 'nail_designer',
      label: 'Nail Designer',
      localMarketCents: 11000,
      travelReserveCents: 2000,
      minimumHomeCents: 11000,
      estimatedMinutes: 120,
      services: [
        'Alongamento em gel',
        'Alongamento em fibra',
        'Molde F1',
        'Banho de gel',
        'Blindagem',
        'Manutenção',
        'Remoção',
      ],
    ),
    RedGlowServiceCategory(
      id: 'maquiadora',
      label: 'Maquiadora',
      localMarketCents: 12000,
      travelReserveCents: 2500,
      minimumHomeCents: 12000,
      estimatedMinutes: 90,
      services: [
        'Maquiagem social',
        'Maquiagem com cílios postiços',
        'Maquiagem para eventos',
        'Maquiagem de noiva',
      ],
    ),
    RedGlowServiceCategory(
      id: 'designer_sobrancelhas',
      label: 'Designer de Sobrancelhas',
      localMarketCents: 3500,
      travelReserveCents: 1500,
      minimumHomeCents: 4000,
      estimatedMinutes: 45,
      services: [
        'Design simples',
        'Design com henna',
        'Brow lamination',
        'Manutenção de design',
      ],
    ),
    RedGlowServiceCategory(
      id: 'lash_designer',
      label: 'Lash Designer',
      localMarketCents: 14000,
      travelReserveCents: 2000,
      minimumHomeCents: 13000,
      estimatedMinutes: 120,
      services: [
        'Fio a fio',
        'Volume brasileiro',
        'Volume fox eye',
        'Volume glamour',
        'Lash lifting',
        'Manutenção',
        'Remoção',
      ],
    ),
  ];

  static List<String> get labels =>
      categories.map((category) => category.label).toList(growable: false);

  static List<String> get allServices => categories
      .expand((category) => category.services)
      .toSet()
      .toList(growable: false);

  static List<String> normalizeLabels(Iterable<String> labels) {
    final normalized = <String>[];
    for (final label in labels) {
      if (!isAllowed(label)) continue;
      final value = normalizeLabel(label);
      if (!normalized.contains(value)) normalized.add(value);
    }
    return List.unmodifiable(normalized);
  }

  static List<RedGlowServiceCategory> categoriesForServices(
    Iterable<String> services,
  ) {
    final selected = services.map((service) => service.trim()).toSet();
    return categories
        .where(
          (category) =>
              category.services.any((service) => selected.contains(service)),
        )
        .toList(growable: false);
  }

  static RedGlowServiceCategory byLabel(String? label) {
    final normalized = label?.trim().toLowerCase();
    for (final category in categories) {
      if (category.label.toLowerCase() == normalized) return category;
    }
    return categories.first;
  }

  static RedGlowServiceCategory byServiceOrLabel(String? value) {
    final normalized = value?.trim().toLowerCase();
    for (final category in categories) {
      if (category.label.toLowerCase() == normalized ||
          category.services.any(
            (service) => service.toLowerCase() == normalized,
          )) {
        return category;
      }
    }
    return categories.first;
  }

  static String normalizeLabel(String? label) => byLabel(label).label;

  static bool isAllowed(String? label) {
    final normalized = label?.trim().toLowerCase();
    return categories.any(
      (category) => category.label.toLowerCase() == normalized,
    );
  }

  static bool isServiceAllowedForCategory(
    String? categoryLabel,
    String? serviceName,
  ) {
    final normalized = serviceName?.trim().toLowerCase();
    return byLabel(categoryLabel).services.any(
      (service) => service.toLowerCase() == normalized,
    );
  }

  static bool isServiceAllowedForCategories(
    Iterable<String> categoryLabels,
    String? serviceName,
  ) {
    return normalizeLabels(categoryLabels).any(
      (category) => isServiceAllowedForCategory(category, serviceName),
    );
  }

  static List<String> validServicesForCategories(
    Iterable<String> categoryLabels,
    Iterable<String> services,
  ) {
    final categories = normalizeLabels(categoryLabels);
    final valid = <String>[];
    for (final service in services) {
      final clean = service.trim();
      if (clean.isEmpty ||
          !isServiceAllowedForCategories(categories, clean) ||
          valid.contains(clean)) {
        continue;
      }
      valid.add(clean);
    }
    return List.unmodifiable(valid);
  }

  static String formatCurrency(int cents) {
    final value = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $value';
  }
}
