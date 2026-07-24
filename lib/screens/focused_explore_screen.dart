import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/service_catalog.dart';
import '../services/firebase_marketplace_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'order_confirmation_screen.dart';

class FocusedExploreScreen extends StatefulWidget {
  const FocusedExploreScreen({super.key});

  @override
  State<FocusedExploreScreen> createState() => _FocusedExploreScreenState();
}

class _FocusedExploreScreenState extends State<FocusedExploreScreen> {
  final _searchController = TextEditingController();
  String _category = 'Todos';
  String? _service;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCategory(String value) {
    setState(() {
      _category = value;
      _service = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    return ConstrainedMobileBody(
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('focused-explore-scroll'),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
          children: [
            Text(
              'Buscar atendimento',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 5),
            Text(
              state.isDemoSession
                  ? 'Vitrine demonstrativa dos nichos REDGLOW.'
                  : 'Escolha o nicho, veja os serviços e encontre profissionais reais online.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('explore-search'),
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Buscar profissional, nicho ou serviço',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 14),
            Text('NICHOS REDGLOW', style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final category in [
                    'Todos',
                    ...RedGlowServiceCatalog.labels,
                  ]) ...[
                    ChoiceChip(
                      key: Key('niche-${category.toLowerCase()}'),
                      label: Text(category),
                      selected: _category == category,
                      onSelected: (_) => _selectCategory(category),
                    ),
                    const SizedBox(width: 7),
                  ],
                ],
              ),
            ),
            if (_category != 'Todos') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'SERVIÇOS DE ${_category.toUpperCase()}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  if (_service != null)
                    TextButton(
                      onPressed: () => setState(() => _service = null),
                      child: const Text('Limpar'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: RedGlowServiceCatalog.byLabel(_category).services
                    .map(
                      (service) => FilterChip(
                        key: Key('service-${service.toLowerCase()}'),
                        label: Text(service),
                        selected: _service == service,
                        onSelected: (selected) => setState(
                          () => _service = selected ? service : null,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 8),
              Text(
                _service == null
                    ? 'Selecione uma especialidade para filtrar as profissionais.'
                    : 'Filtro ativo: $_service',
                style: const TextStyle(
                  fontSize: 8,
                  color: AppColors.textMuted,
                ),
              ),
            ],
            const SizedBox(height: 18),
            if (state.isDemoSession)
              _ProfessionalsList(
                professionals: _demoProfessionals,
                category: _category,
                service: _service,
                query: _searchController.text,
                demo: true,
              )
            else if (Firebase.apps.isEmpty)
              const _InfoCard(
                icon: Icons.cloud_off_outlined,
                title: 'Firebase não conectado',
                message: 'A busca real depende da configuração do Firebase.',
              )
            else
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('professionals')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const _InfoCard(
                      icon: Icons.error_outline_rounded,
                      title: 'Não foi possível carregar',
                      message: 'Confira sua conexão e tente novamente.',
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final professionals = snapshot.data!.docs
                      .map(_SearchProfessional.fromDocument)
                      .where((professional) => professional.isOnline)
                      .toList()
                    ..sort((a, b) => a.name.compareTo(b.name));
                  return _ProfessionalsList(
                    professionals: professionals,
                    category: _category,
                    service: _service,
                    query: _searchController.text,
                    demo: false,
                  );
                },
              ),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalsList extends StatelessWidget {
  const _ProfessionalsList({
    required this.professionals,
    required this.category,
    required this.service,
    required this.query,
    required this.demo,
  });

  final List<_SearchProfessional> professionals;
  final String category;
  final String? service;
  final String query;
  final bool demo;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim().toLowerCase();
    final results = professionals.where((professional) {
      final matchesCategory =
          category == 'Todos' || professional.specialty == category;
      final matchesService = service == null ||
          professional.services.any(
            (item) => item.toLowerCase() == service!.toLowerCase(),
          );
      final matchesQuery = normalizedQuery.isEmpty ||
          professional.name.toLowerCase().contains(normalizedQuery) ||
          professional.specialty.toLowerCase().contains(normalizedQuery) ||
          professional.services.any(
            (item) => item.toLowerCase().contains(normalizedQuery),
          );
      return matchesCategory && matchesService && matchesQuery;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: results.length == 1
              ? '1 profissional encontrada'
              : '${results.length} profissionais encontradas',
        ),
        const SizedBox(height: 9),
        if (results.isEmpty)
          _InfoCard(
            icon: Icons.person_search_outlined,
            title: 'Nenhuma profissional disponível',
            message: category == 'Todos'
                ? 'Ainda não há profissionais reais online para esta busca.'
                : 'O nicho e seus serviços continuam disponíveis, mas ainda não existe uma profissional online com esse perfil.',
          )
        else
          for (final professional in results)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: GlowCard(
                onTap: () => _openProfessional(context, professional, demo),
                padding: const EdgeInsets.all(11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ProfileAvatar(
                          imageUrl: professional.photoUrl,
                          size: 52,
                          fallbackIcon: Icons.badge_outlined,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                professional.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                professional.specialty,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              RedGlowServiceCatalog.formatCurrency(
                                professional.priceCents,
                              ),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            StatusPill(
                              label: demo ? 'DEMO' : 'ONLINE',
                              color: demo ? AppColors.purple : AppColors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: professional.services
                          .take(4)
                          .map(
                            (item) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceRaised,
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 8),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  void _openProfessional(
    BuildContext context,
    _SearchProfessional professional,
    bool demo,
  ) {
    final state = DemoAppScope.of(context, listen: false);
    if (demo && !professional.bookable) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professional.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '${professional.specialty}. Esta é uma vitrine demonstrativa; apenas Lari está liberada para testar o fluxo de pedido.',
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    state.selectedProfessional = MarketplaceProfessional(
      uid: professional.uid,
      name: professional.name,
      specialty: professional.specialty,
      priceCents: professional.priceCents,
      isOnline: professional.isOnline,
      photoUrl: professional.photoUrl.isEmpty ? null : professional.photoUrl,
    );
    state.notifyListeners();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrderConfirmationScreen()),
    );
  }
}

class _SearchProfessional {
  const _SearchProfessional({
    required this.uid,
    required this.name,
    required this.specialty,
    required this.priceCents,
    required this.services,
    required this.isOnline,
    required this.photoUrl,
    this.bookable = true,
  });

  final String uid;
  final String name;
  final String specialty;
  final int priceCents;
  final List<String> services;
  final bool isOnline;
  final String photoUrl;
  final bool bookable;

  factory _SearchProfessional.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final specialty = RedGlowServiceCatalog.normalizeLabel(
      data['specialty'] as String?,
    );
    final category = RedGlowServiceCatalog.byLabel(specialty);
    final rawServices = data['services'];
    final services = rawServices is List
        ? rawServices.whereType<String>().toList(growable: false)
        : category.services;
    return _SearchProfessional(
      uid: document.id,
      name: data['name'] as String? ?? 'Profissional REDGLOW',
      specialty: specialty,
      priceCents:
          data['priceCents'] as int? ?? category.recommendedHomeCents,
      services: services.isEmpty ? category.services : services,
      isOnline: data['isOnline'] as bool? ?? false,
      photoUrl: data['photoUrl'] as String? ?? '',
    );
  }
}

const _demoProfessionals = <_SearchProfessional>[
  _SearchProfessional(
    uid: 'demo-lari',
    name: 'Lari (Manicure)',
    specialty: 'Manicure',
    priceCents: 6000,
    services: [
      'Manicure tradicional',
      'Esmaltação em gel',
      'Spa das mãos',
    ],
    isOnline: true,
    photoUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=240',
  ),
  _SearchProfessional(
    uid: 'demo-pedicure',
    name: 'Vitrine Pedicure',
    specialty: 'Pedicure',
    priceCents: 5500,
    services: ['Pedicure tradicional', 'Spa dos pés'],
    isOnline: true,
    photoUrl: '',
    bookable: false,
  ),
  _SearchProfessional(
    uid: 'demo-nails',
    name: 'Vitrine Nail Designer',
    specialty: 'Nail Designer',
    priceCents: 13000,
    services: ['Alongamento em gel', 'Blindagem', 'Manutenção'],
    isOnline: true,
    photoUrl: '',
    bookable: false,
  ),
  _SearchProfessional(
    uid: 'demo-makeup',
    name: 'Vitrine Maquiadora',
    specialty: 'Maquiadora',
    priceCents: 14500,
    services: ['Maquiagem social', 'Maquiagem para eventos'],
    isOnline: true,
    photoUrl: '',
    bookable: false,
  ),
  _SearchProfessional(
    uid: 'demo-brows',
    name: 'Vitrine Sobrancelhas',
    specialty: 'Designer de Sobrancelhas',
    priceCents: 5000,
    services: ['Design simples', 'Design com henna'],
    isOnline: true,
    photoUrl: '',
    bookable: false,
  ),
  _SearchProfessional(
    uid: 'demo-lashes',
    name: 'Vitrine Lash Designer',
    specialty: 'Lash Designer',
    priceCents: 16000,
    services: ['Fio a fio', 'Volume brasileiro', 'Lash lifting'],
    isOnline: true,
    photoUrl: '',
    bookable: false,
  ),
];

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      child: Column(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 38),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
