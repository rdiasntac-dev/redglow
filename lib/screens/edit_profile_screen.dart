import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/service_catalog.dart';
import '../models/user_role.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.role});

  final UserRole role;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;
  String _selectedCategory = RedGlowServiceCatalog.categories.first.label;

  RedGlowServiceCategory get _category =>
      RedGlowServiceCatalog.byLabel(_selectedCategory);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final state = DemoAppScope.of(context, listen: false);
    final isProvider = widget.role == UserRole.provider;
    _nameController.text = state.accountName ??
        (state.isDemoSession
            ? isProvider
                ? 'Lari (Manicure)'
                : 'Cliente REDGLOW'
            : '');
    _phoneController.text =
        state.accountPhone ?? (state.isDemoSession ? '(41) 99999-9999' : '');
    _selectedCategory = RedGlowServiceCatalog.normalizeLabel(
      state.providerSpecialty,
    );
    final currentPrice = state.providerPriceCents > 0
        ? state.providerPriceCents
        : _category.recommendedHomeCents;
    _priceController.text = _formatPriceForField(currentPrice);
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _formatPriceForField(int cents) =>
      (cents / 100).toStringAsFixed(2).replaceAll('.', ',');

  int? _parsePriceCents() {
    final rawPrice = _priceController.text.trim();
    final priceDigits = rawPrice.replaceAll(RegExp(r'\D'), '');
    final parsedPrice = int.tryParse(priceDigits);
    if (parsedPrice == null) return null;
    return rawPrice.contains(',') || rawPrice.contains('.')
        ? parsedPrice
        : parsedPrice * 100;
  }

  Future<bool> _confirmBelowReference(int priceCents) async {
    if (priceCents >= _category.minimumHomeCents) return true;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Valor abaixo da referência'),
            content: Text(
              'Para atendimento domiciliar em São José dos Pinhais, o valor mínimo sugerido para ${_category.label} é '
              '${RedGlowServiceCatalog.formatCurrency(_category.minimumHomeCents)}. '
              'Um valor menor pode não cobrir material, tempo e deslocamento. Deseja salvar mesmo assim?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Revisar valor'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Salvar mesmo assim'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _save() async {
    final priceCents = _parsePriceCents();
    if (widget.role == UserRole.provider &&
        priceCents != null &&
        !await _confirmBelowReference(priceCents)) {
      return;
    }
    if (!mounted) return;
    setState(() => _saving = true);
    final state = DemoAppScope.of(context, listen: false);
    final succeeded = await state.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      specialty: widget.role == UserRole.provider ? _selectedCategory : null,
      priceCents: widget.role == UserRole.provider ? priceCents : null,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.backendError ?? 'Não foi possível salvar.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso.')),
    );
    Navigator.of(context).pop();
  }

  void _selectCategory(String? value) {
    if (value == null) return;
    final category = RedGlowServiceCatalog.byLabel(value);
    setState(() {
      _selectedCategory = category.label;
      _priceController.text = _formatPriceForField(
        category.recommendedHomeCents,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = DemoAppScope.of(context);
    final isProvider = widget.role == UserRole.provider;
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
                  Expanded(
                    child: Text(
                      isProvider ? 'Perfil profissional' : 'Editar perfil',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceRaised,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isProvider
                            ? Icons.badge_outlined
                            : Icons.person_outline_rounded,
                        color: AppColors.textSecondary,
                        size: 34,
                      ),
                    ),
                    Positioned(
                      right: -3,
                      bottom: -3,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'O envio de foto será conectado ao armazenamento seguro antes do beta público.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 8, color: AppColors.textMuted),
              ),
              const SizedBox(height: 18),
              GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(isProvider ? 'NOME PROFISSIONAL' : 'NOME'),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('profile-name-field'),
                      controller: _nameController,
                      maxLength: 60,
                      decoration: const InputDecoration(
                        hintText: 'Como deseja aparecer no REDGLOW',
                        counterText: '',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 13),
                    const _FieldLabel('CELULAR'),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('profile-phone-field'),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        hintText: '(41) 99999-9999',
                        counterText: '',
                        prefixIcon: Icon(Icons.phone_android_rounded),
                      ),
                    ),
                    if (isProvider) ...[
                      const SizedBox(height: 13),
                      const _FieldLabel('NICHO PRINCIPAL'),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        key: const Key('profile-specialty-field'),
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
                        onChanged: _selectCategory,
                      ),
                      const SizedBox(height: 10),
                      _CategoryReferenceCard(category: _category),
                      const SizedBox(height: 13),
                      const _FieldLabel('VALOR BASE DO ATENDIMENTO'),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('profile-price-field'),
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9,.]'),
                          ),
                        ],
                        decoration: InputDecoration(
                          hintText: _formatPriceForField(
                            _category.recommendedHomeCents,
                          ),
                          prefixText: 'R\$ ',
                          prefixIcon: const Icon(Icons.payments_outlined),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (state.isDemoSession) ...[
                const SizedBox(height: 10),
                const GlowCard(
                  borderColor: Color(0xFF5E4D24),
                  color: Color(0xFF211D10),
                  child: Row(
                    children: [
                      Icon(Icons.science_outlined, color: AppColors.yellow),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Na demonstração, as alterações permanecem apenas durante a sessão atual.',
                          style: TextStyle(
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
                key: const Key('save-profile'),
                label: _saving ? 'Salvando...' : 'Salvar alterações',
                icon: Icons.check_rounded,
                enabled: !_saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryReferenceCard extends StatelessWidget {
  const _CategoryReferenceCard({required this.category});

  final RedGlowServiceCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.primary.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_outlined,
                color: AppColors.primary,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Referência domiciliar em São José dos Pinhais',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '${RedGlowServiceCatalog.formatCurrency(category.recommendedHomeCents)} sugeridos · '
            '${RedGlowServiceCatalog.formatCurrency(category.travelReserveCents)} reservados para deslocamento · '
            '${category.estimatedMinutes} min estimados',
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: category.services
                .map(
                  (service) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      service,
                      style: const TextStyle(fontSize: 8),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.labelSmall);
  }
}
