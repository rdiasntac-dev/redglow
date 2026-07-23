import 'package:flutter/material.dart';

import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  static const _categories = [
    'Segurança',
    'Conduta',
    'Pagamento',
    'Problema técnico',
    'Outro',
  ];

  final _descriptionController = TextEditingController();
  String _category = _categories.first;
  bool _sending = false;
  bool _sent = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _sending = true);
    final state = DemoAppScope.of(context, listen: false);
    final succeeded = await state.submitReport(
      category: _category,
      description: _descriptionController.text,
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = succeeded;
    });
    if (!succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.backendError ?? 'Não foi possível enviar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return Scaffold(
        body: ConstrainedMobileBody(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.task_alt_rounded, color: AppColors.green, size: 72),
                    const SizedBox(height: 16),
                    const Text('Relato enviado', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 7),
                    const Text(
                      'O registro entrou na fila da Central REDGLOW. Em risco imediato, use o SOS e contate o serviço público adequado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 22),
                    GradientButton(
                      label: 'Voltar',
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

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
                    child: Text('Relatar uma situação', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const GlowCard(
                borderColor: Color(0xFF6E2434),
                color: Color(0xFF211017),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFFF667A)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Este formulário não substitui o atendimento emergencial. Em risco imediato, afaste-se do local e use o SOS.',
                        style: TextStyle(fontSize: 9, height: 1.45, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlowCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CATEGORIA', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: [
                        for (final category in _categories)
                          FilterChip(
                            selected: _category == category,
                            showCheckmark: false,
                            label: Text(category),
                            onSelected: (_) => setState(() => _category = category),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('DESCRIÇÃO', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 7),
                    TextField(
                      key: const Key('report-description'),
                      controller: _descriptionController,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: 'Explique objetivamente o que aconteceu...',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GradientButton(
                key: const Key('submit-report'),
                label: _sending ? 'Enviando...' : 'Enviar relato',
                icon: Icons.send_rounded,
                enabled: !_sending,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
