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
  /// Preços de referência por procedimento para o beta local.
  ///
  /// A profissional pode cobrar acima destes valores. O valor mínimo evita que
  /// deslocamento, material e tempo sejam ignorados no atendimento domiciliar.
  static const Map<String, int> _referencePricesCents = {
    'Manicure tradicional': 6000,
    'Esmaltação em gel': 7500,
    'Spa das mãos': 6500,
    'Remoção de esmaltação em gel': 4500,
    'Pedicure tradicional': 7000,
    'Esmaltação em gel nos pés': 8500,
    'Spa dos pés': 7500,
    'Manicure e pedicure': 12000,
    'Alongamento em gel': 15000,
    'Alongamento em fibra': 18000,
    'Molde F1': 16000,
    'Banho de gel': 11000,
    'Blindagem': 9000,
    'Manutenção': 12000,
    'Remoção': 6500,
    'Maquiagem social': 14500,
    'Maquiagem com cílios postiços': 16500,
    'Maquiagem para eventos': 19000,
    'Maquiagem de noiva': 35000,
    'Design simples': 5000,
    'Design com henna': 6500,
    'Brow lamination': 12000,
    'Manutenção de design': 4500,
    'Fio a fio': 16000,
    'Volume brasileiro': 18000,
    'Volume fox eye': 20000,
    'Volume glamour': 22000,
    'Lash lifting': 14000,
  };

  static const Map<String, int> _minimumPricesCents = {
    'Manicure tradicional': 4500,
    'Esmaltação em gel': 5500,
    'Spa das mãos': 5000,
    'Remoção de esmaltação em gel': 4000,
    'Pedicure tradicional': 5500,
    'Esmaltação em gel nos pés': 6500,
    'Spa dos pés': 5500,
    'Manicure e pedicure': 9000,
    'Alongamento em gel': 11000,
    'Alongamento em fibra': 13000,
    'Molde F1': 12000,
    'Banho de gel': 8500,
    'Blindagem': 7000,
    'Manutenção': 9000,
    'Remoção': 5000,
    'Maquiagem social': 12000,
    'Maquiagem com cílios postiços': 13500,
    'Maquiagem para eventos': 15000,
    'Maquiagem de noiva': 25000,
    'Design simples': 4000,
    'Design com henna': 5000,
    'Brow lamination': 9000,
    'Manutenção de design': 4000,
    'Fio a fio': 13000,
    'Volume brasileiro': 14500,
    'Volume fox eye': 16000,
    'Volume glamour': 18000,
    'Lash lifting': 11000,
  };

  static const Map<String, int> _durationMinutes = {
    'Manicure tradicional': 60,
    'Esmaltação em gel': 75,
    'Spa das mãos': 70,
    'Remoção de esmaltação em gel': 35,
    'Pedicure tradicional': 75,
    'Esmaltação em gel nos pés': 90,
    'Spa dos pés': 85,
    'Manicure e pedicure': 120,
    'Alongamento em gel': 150,
    'Alongamento em fibra': 180,
    'Molde F1': 160,
    'Banho de gel': 110,
    'Blindagem': 90,
    'Manutenção': 120,
    'Remoção': 60,
    'Maquiagem social': 90,
    'Maquiagem com cílios postiços': 105,
    'Maquiagem para eventos': 120,
    'Maquiagem de noiva': 180,
    'Design simples': 45,
    'Design com henna': 60,
    'Brow lamination': 90,
    'Manutenção de design': 40,
    'Fio a fio': 150,
    'Volume brasileiro': 180,
    'Volume fox eye': 190,
    'Volume glamour': 210,
    'Lash lifting': 120,
  };

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

  static int referencePriceCents(String service) {
    final clean = service.trim();
    return _referencePricesCents[clean] ??
        byServiceOrLabel(clean).recommendedHomeCents;
  }

  static int minimumPriceCents(String service) {
    final clean = service.trim();
    return _minimumPricesCents[clean] ??
        byServiceOrLabel(clean).minimumHomeCents;
  }

  static int estimatedMinutesForService(String service) {
    final clean = service.trim();
    return _durationMinutes[clean] ?? byServiceOrLabel(clean).estimatedMinutes;
  }

  /// Pontos são creditados somente quando o atendimento é concluído.
  static int pointsForService(String service) {
    final price = referencePriceCents(service);
    return (price / 600).round().clamp(5, 60).toInt();
  }

  static Map<String, int> defaultPricesForServices(
    Iterable<String> services,
  ) {
    return Map.unmodifiable({
      for (final service in services)
        if (allServices.contains(service)) service: referencePriceCents(service),
    });
  }

  static Map<String, int> sanitizeServicePrices(
    Iterable<String> services,
    Object? rawPrices,
  ) {
    final source = rawPrices is Map
        ? Map<String, dynamic>.from(rawPrices)
        : const <String, dynamic>{};
    return Map.unmodifiable({
      for (final service in services)
        service: ((source[service] as num?)?.round() ??
                referencePriceCents(service))
            .clamp(minimumPriceCents(service), 1000000)
            .toInt(),
    });
  }

  static int totalPriceCents(
    Iterable<String> services,
    Map<String, int> prices,
  ) => services.fold(
        0,
        (total, service) =>
            total + (prices[service] ?? referencePriceCents(service)),
      );

  static int totalMinutes(Iterable<String> services) => services.fold(
        0,
        (total, service) => total + estimatedMinutesForService(service),
      );

  static int totalPoints(Iterable<String> services) => services.fold(
        0,
        (total, service) => total + pointsForService(service),
      );

  /// Converte valores digitados em teclados brasileiros ou internacionais.
  /// Aceita, por exemplo, `60`, `60,00`, `60.00` e `1.200,50`.
  static int? parseCurrencyInputToCents(String input) {
    var clean = input.replaceAll(RegExp(r'[^0-9,.]'), '');
    if (clean.isEmpty) return null;

    final comma = clean.lastIndexOf(',');
    final dot = clean.lastIndexOf('.');
    final decimalIndex = comma > dot ? comma : dot;
    final decimalDigits =
        decimalIndex < 0 ? 0 : clean.length - decimalIndex - 1;
    if (decimalIndex >= 0 && decimalDigits <= 2) {
      final integerPart = clean
          .substring(0, decimalIndex)
          .replaceAll(RegExp(r'[,.]'), '');
      final fractionPart = clean.substring(decimalIndex + 1);
      clean = '$integerPart.$fractionPart';
    } else {
      clean = clean.replaceAll(RegExp(r'[,.]'), '');
    }

    final parsed = double.tryParse(clean);
    return parsed == null ? null : (parsed * 100).round();
  }

  static String formatCurrency(int cents) {
    final value = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $value';
  }
}
