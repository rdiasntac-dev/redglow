import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/service_catalog.dart';
import '../models/user_role.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'edit_profile_screen.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() =>
      _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  bool _loading = true;
  bool _saving = false;
  String? _error;
  final Set<String> _selectedCategories = {};
  final Set<String> _selectedServices = {};
  final Map<String, int> _servicePricesCents = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final state = DemoAppScope.of(context, listen: false);
    if (state.isDemoSession) {
      setState(() {
        _selectedCategories
          ..clear()
          ..addAll(state.providerSpecialties);
        _selectedServices
          ..clear()
          ..addAll(state.demoProviderServices);
        _servicePricesCents
          ..clear()
          ..addAll(state.demoProviderServicePricesCents);
        _loading = false;
      });
      return;
    }

    if (Firebase.apps.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Firebase não conectado.';
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _loading = false;
        _error = 'Sua sessão expirou. Entre novamente.';
      });
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('professionals')
          .doc(user.uid)
          .get();
      final data = snapshot.data() ?? const <String, dynamic>{};
      final primaryCategory = RedGlowServiceCatalog.byLabel(
        data['specialty'] as String?,
      );
      final rawSpecialties = data['specialties'];
      final specialties = RedGlowServiceCatalog.normalizeLabels(
        rawSpecialties is List
            ? rawSpecialties.whereType<String>()
            : <String>[primaryCategory.label],
      );
      final effectiveSpecialties = specialties.isEmpty
          ? <String>[primaryCategory.label]
          : specialties;
      final rawServices = data['services'];
      final services = RedGlowServiceCatalog.validServicesForCategories(
        effectiveSpecialties,
        rawServices is List ? rawServices.whereType<String>() : const <String>[],
      );
      final servicePrices = RedGlowServiceCatalog.sanitizeServicePrices(
        services,
        data['servicePricesCents'],
      );
      if (!mounted) return;
      setState(() {
        _selectedCategories
          ..clear()
          ..addAll(effectiveSpecialties);
        _selectedServices
          ..clear()
          ..addAll(services);
        _servicePricesCents
          ..clear()
          ..addAll(servicePrices);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Não foi possível carregar seus serviços.';
      });
    }
  }

  Future<void> _save() async {
    if (_selectedCategories.isEmpty || _selectedServices.isEmpty) {
      setState(
        () => _error =
            'Selecione pelo menos um nicho e um serviço que você realiza.',
      );
      return;
    }
    for (final service in _selectedServices) {
      final price = _servicePricesCents[service] ?? 0;
      final minimum = RedGlowServiceCatalog.minimumPriceCents(service);
      if (price < minimum) {
        setState(
          () => _error =
              '$service precisa respeitar o mínimo domiciliar de ${RedGlowServiceCatalog.formatCurrency(minimum)}.',
        );
        return;
      }
    }

    final state = DemoAppScope.of(context, listen: false);
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final updated = await state.updateProviderServices(
        specialties: _selectedCategories.toList(growable: false),
        services: _selectedServices.toList(growable: false),
        servicePricesCents: _servicePricesCents,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      if (!updated) {
        setState(() {
          _error = state.backendError ??
              'Não foi possível atualizar seus serviços.';
        });
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.isDemoSession
                ? 'Serviços atualizados nesta demonstração.'
                : 'Serviços profissionais atualizados.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error.code == 'permission-denied'
            ? 'As regras do Firebase ainda precisam ser atualizadas para salvar os serviços.'
            : 'Não foi possível salvar seus serviços agora.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Não foi possível salvar seus serviços agora.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedMobileBody(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
            children: [
              Row(
                children: [
                  RoundIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 11),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Serviços que realizo',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Escolha somente o que você realmente oferece',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlowCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(
                      role: UserRole.provider,
                    ),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.manage_accounts_outlined,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foto e dados profissionais',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Edite foto, nome e telefone de contato',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                GlowCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NICHOS E ESPECIALIDADES',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Você pode atuar em mais de um nicho. Marque apenas os serviços que consegue comprovar e executar.',
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final category
                          in RedGlowServiceCatalog.categories) ...[
                        _CategoryServiceSelector(
                          category: category,
                          enabled:
                              _selectedCategories.contains(category.label),
                          selectedServices: _selectedServices,
                          servicePricesCents: _servicePricesCents,
                          onCategoryChanged: (enabled) => setState(() {
                            if (enabled) {
                              _selectedCategories.add(category.label);
                            } else {
                              _selectedCategories.remove(category.label);
                              _selectedServices.removeAll(category.services);
                              for (final service in category.services) {
                                _servicePricesCents.remove(service);
                              }
                            }
                            _error = null;
                          }),
                          onServiceChanged: (service, selected) =>
                              setState(() {
                            if (selected) {
                              _selectedCategories.add(category.label);
                              _selectedServices.add(service);
                              _servicePricesCents.putIfAbsent(
                                service,
                                () => RedGlowServiceCatalog.referencePriceCents(
                                  service,
                                ),
                              );
                            } else {
                              _selectedServices.remove(service);
                              _servicePricesCents.remove(service);
                            }
                            _error = null;
                          }),
                          onPriceChanged: (service, priceCents) => setState(() {
                            _servicePricesCents[service] = priceCents;
                            _error = null;
                          }),
                        ),
                        const SizedBox(height: 9),
                      ],
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: .32),
                          ),
                        ),
                        child: Text(
                          '${_selectedCategories.length} nicho(s) e ${_selectedServices.length} serviço(s) selecionado(s). A cliente verá somente o que foi informado e aprovado.',
                          style: const TextStyle(
                            fontSize: 9,
                            height: 1.4,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  GlowCard(
                    borderColor: Colors.redAccent.withValues(alpha: .45),
                    color: Colors.redAccent.withValues(alpha: .07),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                GradientButton(
                  key: const Key('save-provider-services'),
                  label: _saving ? 'Salvando...' : 'Salvar serviços',
                  icon: Icons.check_rounded,
                  enabled: !_saving,
                  onPressed: _save,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryServiceSelector extends StatelessWidget {
  const _CategoryServiceSelector({
    required this.category,
    required this.enabled,
    required this.selectedServices,
    required this.servicePricesCents,
    required this.onCategoryChanged,
    required this.onServiceChanged,
    required this.onPriceChanged,
  });

  final RedGlowServiceCategory category;
  final bool enabled;
  final Set<String> selectedServices;
  final Map<String, int> servicePricesCents;
  final ValueChanged<bool> onCategoryChanged;
  final void Function(String service, bool selected) onServiceChanged;
  final void Function(String service, int priceCents) onPriceChanged;

  @override
  Widget build(BuildContext context) {
    final selectedCount =
        category.services.where(selectedServices.contains).length;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.primary.withValues(alpha: .07)
            : AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled
              ? AppColors.primary.withValues(alpha: .45)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      enabled
                          ? '$selectedCount serviço(s) marcado(s)'
                          : 'Ativar este nicho',
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                key: Key('provider-category-${category.id}'),
                value: enabled,
                onChanged: onCategoryChanged,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: category.services
                  .map(
                    (service) => FilterChip(
                      key: Key(
                        'provider-service-${category.id}-${service.toLowerCase()}',
                      ),
                      label: Text(service),
                      selected: selectedServices.contains(service),
                      onSelected: (selected) =>
                          onServiceChanged(service, selected),
                    ),
                  )
                  .toList(growable: false),
            ),
            for (final service
                in category.services.where(selectedServices.contains)) ...[
              const SizedBox(height: 8),
              TextFormField(
                key: Key('provider-price-$service'),
                initialValue: ((servicePricesCents[service] ??
                            RedGlowServiceCatalog.referencePriceCents(service)) /
                        100)
                    .toStringAsFixed(2)
                    .replaceAll('.', ','),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: service,
                  prefixText: 'R\$ ',
                  helperText:
                      'Mínimo domiciliar: ${RedGlowServiceCatalog.formatCurrency(RedGlowServiceCatalog.minimumPriceCents(service))}',
                  suffixIcon: const Icon(Icons.edit_outlined, size: 17),
                ),
                onChanged: (value) {
                  onPriceChanged(
                    service,
                    RedGlowServiceCatalog.parseCurrencyInputToCents(value) ??
                        0,
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }
}
