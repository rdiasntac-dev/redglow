import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class IdentityVerificationScreen extends StatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _started = false;
  bool _cpfDone = false;
  bool _documentDone = false;
  bool _selfieDone = false;
  bool _loading = false;

  int get _completedSteps => [_cpfDone, _documentDone, _selfieDone].where((item) => item).length;

  @override
  void dispose() {
    _cpfController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _verifyCpf() async {
    if (_cpfController.text.length < 11 || _phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha um CPF e um celular válidos.')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _cpfDone = true;
    });
  }

  void _startOrFinish() {
    if (!_started) {
      setState(() => _started = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comece preenchendo CPF e celular.')),
      );
      return;
    }

    if (_completedSteps < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conclua as ${3 - _completedSteps} etapa(s) restante(s).')),
      );
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _completedSteps / 3;
    return Scaffold(
      body: ConstrainedMobileBody(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 22),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 10),
              const _SecurityHero(),
              const SizedBox(height: 16),
              if (_started) ...[
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceRaised,
                          valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${(progress * 100).round()}%', style: const TextStyle(fontSize: 9, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              _StepCard(
                step: 1,
                icon: Icons.badge_outlined,
                title: 'Validação de CPF / Telefone',
                subtitle: 'Verificação instantânea na Receita Federal.',
                active: _started,
                completed: _cpfDone,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CPF', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    TextField(
                      key: const Key('cpf-field'),
                      controller: _cpfController,
                      enabled: _started && !_cpfDone,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      decoration: const InputDecoration(hintText: '000.000.000-00'),
                    ),
                    const SizedBox(height: 8),
                    const Text('Celular', style: TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    TextField(
                      key: const Key('phone-field'),
                      controller: _phoneController,
                      enabled: _started && !_cpfDone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      decoration: const InputDecoration(hintText: '(41) 99999-9999'),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: !_started || _cpfDone || _loading ? null : _verifyCpf,
                        style: FilledButton.styleFrom(
                          backgroundColor: _cpfDone ? AppColors.green : AppColors.surfaceRaised,
                          disabledBackgroundColor: _cpfDone
                              ? AppColors.green.withOpacity(.35)
                              : AppColors.surfaceRaised,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: _loading
                            ? const SizedBox.square(
                                dimension: 14,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(_cpfDone ? Icons.check_rounded : Icons.verified_outlined, size: 16),
                        label: Text(_cpfDone ? 'CPF e telefone verificados' : 'Verificar Agora'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _StepCard(
                step: 2,
                icon: Icons.upload_file_rounded,
                title: 'Envio de Documento Oficial',
                subtitle: 'Frente do RG ou CNH.',
                active: _cpfDone,
                completed: _documentDone,
                child: InkWell(
                  key: const Key('document-upload'),
                  onTap: !_cpfDone
                      ? null
                      : () => setState(() => _documentDone = !_documentDone),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    height: 142,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceRaised.withOpacity(.38),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: _documentDone ? AppColors.green : AppColors.purple.withOpacity(.55),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _documentDone ? Icons.check_circle_rounded : Icons.note_add_outlined,
                          size: 37,
                          color: _documentDone ? AppColors.green : AppColors.purple,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _documentDone ? 'Documento recebido' : 'Toque para enviar',
                          style: const TextStyle(fontSize: 11, color: AppColors.purple, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        const Text('RG ou CNH · JPG / PNG · máx. 10 MB', style: TextStyle(fontSize: 7, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _StepCard(
                step: 3,
                icon: Icons.face_retouching_natural_rounded,
                title: 'Selfie com Prova de Vida',
                subtitle: 'Biometria facial anti-spoofing ativa.',
                active: _documentDone,
                completed: _selfieDone,
                child: Column(
                  children: [
                    Container(
                      width: 108,
                      height: 108,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceRaised.withOpacity(.4),
                        border: Border.all(
                          color: _selfieDone ? AppColors.green : AppColors.route.withOpacity(.7),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selfieDone ? Icons.check_circle_rounded : Icons.camera_front_rounded,
                            color: _selfieDone ? AppColors.green : AppColors.route,
                            size: 28,
                          ),
                          const SizedBox(height: 6),
                          StatusPill(
                            label: _selfieDone ? 'VALIDADO' : 'ANTI-SPOOFING ATIVO',
                            color: _selfieDone ? AppColors.green : AppColors.route,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Evita fraudes com fotos impressas ou telas.\nProteção bilateral para cada atendimento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 7, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 9),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const Key('selfie-button'),
                        onPressed: !_documentDone
                            ? null
                            : () => setState(() => _selfieDone = !_selfieDone),
                        icon: Icon(_selfieDone ? Icons.check_rounded : Icons.camera_alt_outlined, size: 16),
                        label: Text(_selfieDone ? 'Selfie validada' : 'Tirar Selfie Agora'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ConstrainedMobileBody(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientButton(
                  key: const Key('start-verification'),
                  label: _completedSteps == 3
                      ? 'Concluir Verificação'
                      : _started
                          ? 'Continuar Verificação'
                          : 'Iniciar Verificação',
                  icon: _completedSteps == 3 ? Icons.check_circle_rounded : Icons.shield_outlined,
                  onPressed: _startOrFinish,
                  gradient: _completedSteps == 3
                      ? const LinearGradient(colors: [Color(0xFF0FBF8B), Color(0xFF0E9F75)])
                      : pinkGradient,
                ),
                const SizedBox(height: 7),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _PrivacySeal(icon: Icons.lock_outline_rounded, label: 'Criptografia\nAES-256'),
                    _PrivacySeal(icon: Icons.gavel_rounded, label: 'LGPD\nCompliant'),
                    _PrivacySeal(icon: Icons.visibility_off_outlined, label: 'Sem retenção\nde dados'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityHero extends StatelessWidget {
  const _SecurityHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(.12),
            border: Border.all(color: AppColors.primary.withOpacity(.55)),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 28)],
          ),
          child: const Icon(Icons.verified_user_outlined, size: 37, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Text('Segurança REDGLOW', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text(
          'Para blindar a comunidade contra perfis falsos\ne garantir atendimentos seguros em domicílio,\nvalidamos a identidade de todos.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.45),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.completed,
    required this.child,
  });

  final int step;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final bool completed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accent = completed ? AppColors.green : AppColors.primary;
    return Opacity(
      opacity: active || completed ? 1 : .42,
      child: GlowCard(
        borderColor: completed ? AppColors.green.withOpacity(.45) : AppColors.border,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(.12),
                    border: Border.all(color: accent.withOpacity(.5)),
                  ),
                  child: Icon(completed ? Icons.check_rounded : icon, size: 17, color: accent),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Passo $step — $title', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                      Text(subtitle, style: const TextStyle(fontSize: 8, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                StatusPill(label: completed ? 'CONCLUÍDO' : 'OBRIGATÓRIO', color: accent),
              ],
            ),
            const SizedBox(height: 11),
            child,
          ],
        ),
      ),
    );
  }
}

class _PrivacySeal extends StatelessWidget {
  const _PrivacySeal({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 6, color: AppColors.textMuted)),
      ],
    );
  }
}
