import 'package:flutter/material.dart';

import '../services/session_service.dart';
import '../state/demo_app_state.dart';
import '../theme/app_theme.dart';

class AccountDeletionButton extends StatefulWidget {
  const AccountDeletionButton({super.key});

  @override
  State<AccountDeletionButton> createState() => _AccountDeletionButtonState();
}

class _AccountDeletionButtonState extends State<AccountDeletionButton> {
  bool _loading = false;

  Future<void> _requestDeletion() async {
    final state = DemoAppScope.of(context, listen: false);
    if (state.isDemoSession) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exclusão de conta'),
          content: const Text(
            'A demonstração não cria uma conta nem envia dados. Em uma conta real, '
            'este botão registra uma solicitação de exclusão para tratamento seguro.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar exclusão?'),
        content: const Text(
          'A solicitação será registrada e sua sessão será encerrada. '
          'Durante o beta, a remoção definitiva será revisada antes de apagar '
          'dados necessários para segurança, obrigações legais ou disputas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Solicitar exclusão'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    final succeeded = await state.requestAccountDeletion();
    if (!mounted) return;
    setState(() => _loading = false);
    if (!succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.backendError ?? 'Não foi possível registrar a solicitação.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Solicitação registrada. A sessão será encerrada.'),
      ),
    );
    await endCurrentSession(context);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('request-account-deletion'),
      onPressed: _loading ? null : _requestDeletion,
      style: TextButton.styleFrom(
        foregroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      icon: _loading
          ? const SizedBox.square(
              dimension: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.delete_outline_rounded, size: 18),
      label: Text(
        _loading ? 'Registrando...' : 'Solicitar exclusão da conta',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}
