import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/service_catalog.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

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
  String _selectedCategory = RedGlowServiceCatalog.categories.first.label;
  final Set<String> _selectedServices = {};

  RedGlowServiceCategory get _category =>
      RedGlowServiceCatalog.byLabel(_selectedCategory);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final state = DemoAppScope.of(context, listen: false);
    if (state.isDemoSession) {
      final category = RedGlowServiceCatalog.byLabel(state.providerSpecialty);
      setState(() {
        _selectedCategory = category.label;
        _selectedServices
          ..clear()
          ..addAll(
            state.demoProviderServices.where(category.services.contains),
          );
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
      final category = RedGlowServiceCatalog.byLabel(
        data['specialty'] as String?,
      );
      final rawServices = data['services'];
      final services = rawServices is List
          ? rawServices.whereType<String>().where(category.services.contains)
          : const Iterable<String>.empty();
      if (!mounted) return;
      setState(() {
        _selectedCategory = category.label;
        _selectedServices
          ..clear()
          ..addAll(services);
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

  void _changeCategory(String? value) {
    if (value == null) return;
    setState(() {
      _selectedCategory = value;
      _selectedServices.clear();
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_selectedServices.isEmpty) {
      setState(() => _error = 'Selecione pelo menos um serviço que você realiza.');
      return;
    }

    final state = DemoAppScope.of(context, listen: false);
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final updated = await state.updateProviderServices(
        specialty: _selectedCategory,
        services: _selectedServices.toList(growable: false),
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
                        'NICHO PRINCIPAL',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 7),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.auto_awesome_rounded),
                        ),
                        items: RedGlowServiceCatalog.labels
                            .map(
                              (label) => DropdownMenuItem<String>(
                                value: label,
                                child: Text(label),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: _changeCategory,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'SELECIONE OS SERVIÇOS',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedServices
                                ..clear()
                                ..addAll(_category.services);
                            }),
                            child: const Text('Marcar todos'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _category.services
                            .map(
                              (service) => FilterChip(
                                key: Key('provider-service-${service.toLowerCase()}'),
                                label: Text(service),
                                selected: _selectedServices.contains(service),
                                onSelected: (selected) => setState(() {
                                  if (selected) {
                                    _selectedServices.add(service);
                                  } else {
                                    _selectedServices.remove(service);
                                  }
                                  _error = null;
                                }),
                              ),
                            )
                            .toList(growable: false),
                      ),
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
                          '${_selectedServices.length} serviço(s) selecionado(s). A cliente verá apenas os serviços informados no seu perfil.',
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
