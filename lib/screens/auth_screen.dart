import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'main_shell.dart';
import 'provider_home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _role = UserRole.client;
  bool _registerMode = false;
  bool _hidePassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openSelectedArea() {
    DemoAppScope.of(context, listen: false).selectRole(_role);
    final destination = _role == UserRole.client
        ? const MainShell()
        : const ProviderHomeScreen();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  void _submit() {
    if (_registerMode && _nameController.text.trim().isEmpty) {
      _showMessage('Informe seu nome para criar a conta.');
      return;
    }
    if (!_emailController.text.contains('@')) {
      _showMessage('Informe um e-mail válido.');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showMessage('A senha precisa ter pelo menos 6 caracteres.');
      return;
    }
    if (_registerMode && !_acceptedTerms) {
      _showMessage('Aceite os termos para continuar.');
      return;
    }
    _openSelectedArea();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedMobileBody(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
            children: [
              const _AuthHero(),
              const SizedBox(height: 22),
              _ModeSelector(
                registerMode: _registerMode,
                onChanged: (value) => setState(() => _registerMode = value),
              ),
              const SizedBox(height: 20),
              Text('COMO VOCÊ QUER USAR O REDGLOW?', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 9),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      key: const Key('client-role'),
                      role: UserRole.client,
                      icon: Icons.favorite_outline_rounded,
                      selected: _role == UserRole.client,
                      color: AppColors.primary,
                      onTap: () => setState(() => _role = UserRole.client),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _RoleCard(
                      key: const Key('provider-role'),
                      role: UserRole.provider,
                      icon: Icons.business_center_outlined,
                      selected: _role == UserRole.provider,
                      color: AppColors.purple,
                      onTap: () => setState(() => _role = UserRole.provider),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GlowCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_registerMode) ...[
                      const _FieldLabel('Nome completo'),
                      const SizedBox(height: 5),
                      TextField(
                        key: const Key('auth-name'),
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Como devemos chamar você?',
                          prefixIcon: Icon(Icons.person_outline_rounded, size: 19),
                        ),
                      ),
                      const SizedBox(height: 11),
                      const _FieldLabel('Celular'),
                      const SizedBox(height: 5),
                      TextField(
                        key: const Key('auth-phone'),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '(41) 99999-9999',
                          prefixIcon: Icon(Icons.phone_outlined, size: 19),
                        ),
                      ),
                      const SizedBox(height: 11),
                    ],
                    const _FieldLabel('E-mail'),
                    const SizedBox(height: 5),
                    TextField(
                      key: const Key('auth-email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        hintText: 'voce@email.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded, size: 19),
                      ),
                    ),
                    const SizedBox(height: 11),
                    const _FieldLabel('Senha'),
                    const SizedBox(height: 5),
                    TextField(
                      key: const Key('auth-password'),
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Mínimo de 6 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 19),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 19,
                          ),
                        ),
                      ),
                    ),
                    if (_registerMode) ...[
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        value: _acceptedTerms,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: AppColors.primary,
                        title: const Text(
                          'Li e aceito os Termos de Uso e a Política de Privacidade.',
                          style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
                        ),
                        onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                      ),
                    ] else
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showMessage(
                            'A recuperação de senha será conectada ao backend.',
                          ),
                          child: const Text(
                            'Esqueci minha senha',
                            style: TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                    GradientButton(
                      key: const Key('auth-submit'),
                      label: _registerMode
                          ? 'Criar conta como ${_role.title}'
                          : 'Entrar como ${_role.title}',
                      icon: _registerMode
                          ? Icons.person_add_alt_1_rounded
                          : Icons.login_rounded,
                      gradient: _role == UserRole.client
                          ? pinkGradient
                          : const LinearGradient(
                              colors: [AppColors.purple, Color(0xFF6428A3)],
                            ),
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text('VISUALIZAÇÃO', style: Theme.of(context).textTheme.labelSmall),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('demo-access'),
                onPressed: _openSelectedArea,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(
                    color: (_role == UserRole.client
                            ? AppColors.primary
                            : AppColors.purple)
                        .withValues(alpha: .6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                icon: const Icon(Icons.play_circle_outline_rounded, size: 19),
                label: Text(
                  'Acessar demonstração como ${_role.title}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 9),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 12, color: AppColors.green),
                  SizedBox(width: 5),
                  Text(
                    'Ambiente demonstrativo · Nenhum dado é enviado',
                    style: TextStyle(fontSize: 7, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: pinkGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: .3),
                blurRadius: 28,
              ),
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded, size: 35, color: Colors.white),
        ),
        const SizedBox(height: 13),
        const Text(
          'REDGLOW',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Beleza que chega até você, com segurança.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.registerMode, required this.onChanged});

  final bool registerMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      padding: const EdgeInsets.all(4),
      radius: AppRadius.md,
      child: Row(
        children: [
          Expanded(
            child: _ModeOption(
              label: 'Entrar',
              selected: !registerMode,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _ModeOption(
              label: 'Criar conta',
              selected: registerMode,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? pinkGradient : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
    super.key,
  });

  final UserRole role;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: .12) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  size: 17,
                  color: selected ? color : AppColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              role.title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              role.description,
              style: const TextStyle(fontSize: 8, color: AppColors.textSecondary),
            ),
          ],
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
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
