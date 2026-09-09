import 'package:flutter/material.dart';

import '../models/service_catalog.dart';
import '../services/firebase_marketplace_service.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

Future<List<String>?> showServiceSelectionSheet(
  BuildContext context, {
  required MarketplaceProfessional professional,
  Iterable<String> initialServices = const [],
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    builder: (_) => _ServiceSelectionSheet(
      professional: professional,
      initialServices: initialServices,
    ),
  );
}

class _ServiceSelectionSheet extends StatefulWidget {
  const _ServiceSelectionSheet({
    required this.professional,
    required this.initialServices,
  });

  final MarketplaceProfessional professional;
  final Iterable<String> initialServices;

  @override
  State<_ServiceSelectionSheet> createState() =>
      _ServiceSelectionSheetState();
}

class _ServiceSelectionSheetState extends State<_ServiceSelectionSheet> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialServices
        .where(widget.professional.services.contains)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final ordered = widget.professional.services
        .where(_selected.contains)
        .toList(growable: false);
    final total = ordered.fold(
      0,
      (sum, service) => sum + widget.professional.priceForService(service),
    );
    final duration = RedGlowServiceCatalog.totalMinutes(ordered);
    final points = RedGlowServiceCatalog.totalPoints(ordered);
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: .86,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escolha seu atendimento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Selecione um ou mais serviços de ${widget.professional.name}. O total é calculado pelos valores cadastrados pela profissional.',
                style: const TextStyle(
                  fontSize: 9,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.professional.services.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 7),
                  itemBuilder: (context, index) {
                    final service = widget.professional.services[index];
                    final category =
                        RedGlowServiceCatalog.byServiceOrLabel(service);
                    final selected = _selected.contains(service);
                    return GlowCard(
                      key: Key('select-service-$service'),
                      onTap: () => setState(() {
                        selected
                            ? _selected.remove(service)
                            : _selected.add(service);
                      }),
                      padding: const EdgeInsets.all(10),
                      borderColor:
                          selected ? AppColors.primary : AppColors.border,
                      color: selected
                          ? AppColors.primary.withValues(alpha: .07)
                          : AppColors.surfaceRaised,
                      child: Row(
                        children: [
                          Checkbox(
                            value: selected,
                            onChanged: (_) => setState(() {
                              selected
                                  ? _selected.remove(service)
                                  : _selected.add(service);
                            }),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${category.label} · ${RedGlowServiceCatalog.estimatedMinutesForService(service)} min · +${RedGlowServiceCatalog.pointsForService(service)} pts',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            RedGlowServiceCatalog.formatCurrency(
                              widget.professional.priceForService(service),
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        ordered.isEmpty
                            ? 'Selecione pelo menos um serviço'
                            : '${ordered.length} serviço(s) · ~$duration min · +$points pts',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      RedGlowServiceCatalog.formatCurrency(total),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GradientButton(
                key: const Key('continue-service-selection'),
                label: 'Continuar com o pedido',
                icon: Icons.arrow_forward_rounded,
                enabled: ordered.isNotEmpty,
onPressed: () => Navigator.of(context).pop(ordered),
            ),
          ],
        ),
      );
    }
  }