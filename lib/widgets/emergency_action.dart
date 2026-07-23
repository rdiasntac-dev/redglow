import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../screens/report_issue_screen.dart';
import 'common_widgets.dart';

Future<void> showEmergencyCenter(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 2, 18, 22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _EmergencyHeader(),
                const SizedBox(height: 16),
                _EmergencyCallTile(
                  key: const Key('emergency-call-190'),
                  number: '190',
                  title: 'Polícia Militar',
                  subtitle: 'Emergência ou risco imediato',
                  onTap: () => _confirmCall(
                    sheetContext,
                    number: '190',
                    service: 'Polícia Militar',
                  ),
                ),
                const SizedBox(height: 9),
                _EmergencyCallTile(
                  key: const Key('emergency-call-153'),
                  number: '153',
                  title: 'Guarda Municipal',
                  subtitle: 'Atendimento municipal de segurança',
                  onTap: () => _confirmCall(
                    sheetContext,
                    number: '153',
                    service: 'Guarda Municipal',
                  ),
                ),
                const SizedBox(height: 14),
                const GlowCard(
                  borderColor: Color(0xFF6E2434),
                  color: Color(0xFF211017),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFFFF667A), size: 18),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'A REDGLOW não substitui os serviços públicos. Se puder, afaste-se do risco e informe sua localização ao atendente.',
                          style: TextStyle(fontSize: 9, height: 1.45, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReportIssueScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.report_outlined),
                    label: const Text('Relatar situação não emergencial'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class EmergencyFloatingButton extends StatelessWidget {
  const EmergencyFloatingButton({
    super.key,
    this.heroTag = 'redglow-emergency',
  });

  final String heroTag;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: heroTag,
      tooltip: 'Central de Segurança',
      backgroundColor: const Color(0xFFE6294B),
      foregroundColor: Colors.white,
      extendedPadding: const EdgeInsets.symmetric(horizontal: 14),
      extendedIconLabelSpacing: 6,
      onPressed: () => showEmergencyCenter(context),
      icon: const Icon(Icons.shield_rounded, size: 19),
      label: const Text(
        'SOS',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _EmergencyHeader extends StatelessWidget {
  const _EmergencyHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE6294B).withValues(alpha: .14),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE6294B).withValues(alpha: .7)),
          ),
          child: const Icon(Icons.shield_rounded, color: Color(0xFFFF526C), size: 25),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Central de Segurança', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              SizedBox(height: 2),
              Text(
                'Escolha o serviço público que deseja chamar.',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmergencyCallTile extends StatelessWidget {
  const _EmergencyCallTile({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final String number;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      onTap: onTap,
      borderColor: const Color(0xFFE6294B).withValues(alpha: .65),
      color: const Color(0xFF211017),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE6294B).withValues(alpha: .16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.call_rounded, color: Color(0xFFFF526C)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            number,
            style: const TextStyle(color: Color(0xFFFF526C), fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmCall(
  BuildContext context, {
  required String number,
  required String service,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Ligar para $number?'),
      content: Text(
        'O REDGLOW abrirá o discador para chamar $service. A ligação só será iniciada após a confirmação do aparelho.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          key: Key('confirm-emergency-call-$number'),
          onPressed: () {
            Navigator.of(dialogContext).pop();
            unawaited(_launchEmergencyNumber(context, number));
          },
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE6294B)),
          icon: const Icon(Icons.call_rounded),
          label: Text('Ligar $number'),
        ),
      ],
    ),
  );
}

Future<void> _launchEmergencyNumber(BuildContext context, String number) async {
  var launched = false;
  try {
    launched = await launchUrl(Uri(scheme: 'tel', path: number));
  } catch (_) {}

  if (launched || !context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Este dispositivo não possui aplicativo de chamadas. Use um telefone e disque $number.',
      ),
    ),
  );
}
