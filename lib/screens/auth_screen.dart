import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../services/firebase_auth_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/brand_logo.dart';
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
  bool _loading = false;
  bool _areaOpen = false;
  FirebaseAuthService? _authService;

  FirebaseAuthService get _auth => _authService ??= FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreSession());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openSelectedArea({
    required UserRole role,
    required bool demo,
    String? accountName,
  }) {
    if (_areaOpen) return;
    _areaOpen = true;
    DemoAppScope.of(context, listen: false).startSession(
      role: role,
      demo: demo,
      name: accountName,
    );
    final destination = role == UserRole.client
        ? const MainShell()
        : const ProviderHomeScreen();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => destination))
        .whenComplete(() {
          if (mounted) _areaOpen = false;
        });
  }

  Future<void> _restoreSession() async {
    if (Firebase.apps.isEmpty || _areaOpen) return;
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final role = await _auth.userRole(user.uid);
      if (!mounted) return;
      _openSelectedArea(
        role: role,
        demo: false,
        accountName: user.displayName,
      );
    } catch (_) {
      try {
        await _auth.signOut();
      } catch (_) {
        // A tela de acesso continua disponível mesmo se a sessão expirada
        // não puder ser encerrada imediatamente.
      }
    }
  }

  Future<void> _submit() async {
    if (_registerMode && _nameController.text.trim().isEmpty) {
      _showMessage('Informe seu nome para criar a conta.');
      return;
    }
    if (_registerMode && _phoneController.text.replaceAll(RegExp(r'\D'), '').length < 10) {
      _showMessage('Informe um celular válido.');
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
      _showMessage('Confirme que você está entrando no ambiente beta.');
      return;
    }

    setState(() => _loading = true);
    try {
      final credential = _registerMode
          ? await _auth.createAccount(
              name: _nameController.text,
              email: _emailController.text,
              phone: _phoneController.text,
              password: _passwordController.text,
              role: _role,
            )
          : await _auth.signIn(
              email: _emailController.text,
              password: _passwordController.text,
            );
      final user = credential.user;
      if (user == null) throw StateError('Conta Firebase indisponível.');

      final accountRole = await _auth.userRole(user.uid);
      if (accountRole != _role) {
        await _auth.signOut();
        if (!mounted) return;
        _showMessage(
          'Esta conta é de ${accountRole.title}. Selecione o perfil correto para entrar.',
        );
        return;
      }

      if (!mounted) return;
      _openSelectedArea(
        role: accountRole,
        demo: false,
        accountName: user.displayName,
      );
    } on FirebaseAuthException catch (error) {
      _showMessage(_firebaseMessage(error.code));
    } on FirebaseException catch (error) {
      _showMessage(_firebaseMessage(error.code));
    } on StateError catch (error) {
      await _auth.signOut();
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Não foi possível acessar sua conta agora. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_emailController.text.contains('@')) {
      _showMessage('Informe seu e-mail antes de recuperar a senha.');
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.sendPasswordReset(_emailController.text);
      _showMessage('Enviamos as instruções de recuperação para seu e-mail.');
    } on FirebaseAuthException catch (error) {
      _showMessage(_firebaseMessage(error.code));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static String _firebaseMessage(String code) => switch (code) {
        'email-already-in-use' => 'Este e-mail já possui uma conta REDGLOW.',
        'invalid-email' => 'Informe um e-mail válido.',
        'weak-password' => 'Crie uma senha mais forte, com pelo menos 6 caracteres.',
        'user-disabled' => 'Esta conta está desativada. Fale com o suporte.',
        'user-not-found' || 'wrong-password' || 'invalid-credential' =>
          'E-mail ou senha incorretos.',
        'too-many-requests' => 'Muitas tentativas. Aguarde alguns minutos.',
        'network-request-failed' => 'Sem conexão com a internet.',
        'operation-not-allowed' =>
          'O login por e-mail ainda precisa ser ativado no Firebase.',
        'permission-denied' =>
          'O acesso ao banco foi bloqueado pelas regras de segurança.',
        _ => 'Não foi possível concluir. Tente novamente.',
      };

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
                          'Estou ciente de que esta é uma versão beta, sem pagamentos reais.',
                          style: TextStyle(fontSize: 8, color: AppColors.textSecondary),
                        ),
                        onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                      ),
                    ] else
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _loading ? null : _resetPassword,
                          child: const Text(
                            'Esqueci minha senha',
                            style: TextStyle(fontSize: 9),
                          ),
                        ),
                      ),
                    GradientButton(
                      key: const Key('auth-submit'),
                      label: _loading
                          ? 'Aguarde...'
                          : _registerMode
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
                      enabled: !_loading,
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
                onPressed: _loading
                    ? null
                    : () => _openSelectedArea(
                          role: _role,
                          demo: true,
                        ),
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
        const RedGlowBrandLockup(),
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
