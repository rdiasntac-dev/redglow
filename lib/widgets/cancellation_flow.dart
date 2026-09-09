import 'package:flutter/material.dart';

import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

Future<bool> showCancellationFlow(
  BuildContext context, {
  required bool asProvider,
}) async {
  final reasons = asProvider
      ? const [
          'Imprevisto pessoal',
          'Endereço fora da área',
          'Serviço incompatível',
          'Risco ou situação insegura',
          'Outro motivo',
        ]
      : const [
          'Mudei de ideia',
          'Horário não serve mais',
          'Prestadora está demorando',
          'Segurança ou emergência',
          'Outro motivo',
        ];
  var selected = reasons.first;
  final otherController = TextEditingController();

  final reason = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => StatefulBuilder(
      builder: (context, setSheetState) {
        final usingOther = selected == 'Outro motivo';
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              2,
              18,
              18 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cancelar atendimento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Informe o motivo para registrar a ocorrência no histórico.',
                    style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  for (final reason in reasons)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: InkWell(
                        onTap: () => setSheetState(() => selected = reason),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected == reason
                                ? AppColors.primary.withValues(alpha: .1)
                                : AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected == reason
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected == reason
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_off_rounded,
                                color: selected == reason
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                size: 18,
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (usingOther) ...[
                    const SizedBox(height: 2),
                    TextField(
                      key: const Key('cancellation-other-reason'),
                      controller: otherController,
                      maxLength: 120,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Descreva brevemente o motivo',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 9),
                  ],
                  const GlowCard(
                    borderColor: Color(0xFF5E4D24),
                    color: Color(0xFF211D10),
                    padding: EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.yellow, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Beta: a taxa calculada é R\$ 0,00 e nenhuma cobrança será realizada. A política definitiva depende da validação jurídica e comercial.',
                            style: TextStyle(fontSize: 8, height: 1.4, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Voltar'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          key: const Key('confirm-cancellation'),
                          onPressed: () {
                            final finalReason = usingOther
                                ? otherController.text.trim()
                                : selected;
                            if (finalReason.isEmpty) {
                              ScaffoldMessenger.of(sheetContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Descreva o motivo do cancelamento.'),
                                ),
                              );
                              return;
                            }
                            Navigator.of(sheetContext).pop(finalReason);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text('Confirmar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  otherController.dispose();
  if (reason == null || !context.mounted) return false;

  final state = DemoAppScope.of(context, listen: false);
  final succeeded = await state.cancelBooking(reason: reason);
  if (!context.mounted) return succeeded;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        succeeded
            ? 'Atendimento cancelado sem cobrança no beta.'
            : state.backendError ?? 'Não foi possível cancelar.',
      ),
    ),
  );
  return succeeded;
}
