import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final _specialtyController = TextEditingController();
  final _priceController = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final state = DemoAppScope.of(context, listen: false);
    _nameController.text = state.accountName ??
        (widget.role == UserRole.provider
            ? 'Lari (Manicure)'
            : 'Cliente REDGLOW');
    _phoneController.text = state.accountPhone ?? '(41) 99999-9999';
    _specialtyController.text = state.providerSpecialty;
    _priceController.text = (state.providerPriceCents / 100)
        .toStringAsFixed(2)
        .replaceAll('.', ',');
    _initialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final rawPrice = _priceController.text.trim();
    final priceDigits = rawPrice.replaceAll(RegExp(r'\D'), '');
    final parsedPrice = int.tryParse(priceDigits);
    final priceCents = parsedPrice == null
        ? null
        : rawPrice.contains(',') || rawPrice.contains('.')
            ? parsedPrice
            : parsedPrice * 100;
    setState(() => _saving = true);
    final state = DemoAppScope.of(context, listen: false);
    final succeeded = await state.updateProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      specialty:
          widget.role == UserRole.provider ? _specialtyController.text : null,
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
                    ProfileAvatar(
                      imageUrl: isProvider
                          ? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=180'
                          : 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=180',
                      size: 82,
                      borderColor: AppColors.primary,
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
                'Envio de foto será conectado ao armazenamento seguro antes do beta público.',
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
                      const _FieldLabel('ESPECIALIDADE PRINCIPAL'),
                      const SizedBox(height: 6),
                      TextField(
                        key: const Key('profile-specialty-field'),
                        controller: _specialtyController,
                        maxLength: 50,
                        decoration: const InputDecoration(
                          hintText: 'Ex.: Manicure',
                          counterText: '',
                          prefixIcon: Icon(Icons.auto_awesome_rounded),
                        ),
                      ),
                      const SizedBox(height: 13),
                      const _FieldLabel('VALOR BASE DO SERVIÇO'),
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
                        decoration: const InputDecoration(
                          hintText: '60,00',
                          prefixText: 'R\$ ',
                          prefixIcon: Icon(Icons.payments_outlined),
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: Theme.of(context).textTheme.labelSmall);
  }
}
