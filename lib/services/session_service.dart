import 'package:flutter/material.dart';

import '../models/user_role.dart';
import '../state/demo_app_state.dart';
import 'firebase_auth_service.dart';

Future<void> endCurrentSession(BuildContext context) async {
  final demoState = DemoAppScope.of(context, listen: false);

  if (!demoState.isDemoSession) {
    try {
      if (demoState.activeRole == UserRole.provider) {
        await demoState.setProviderOnline(false);
      }
      await FirebaseAuthService().signOut();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível sair agora. Verifique sua conexão.'),
        ),
      );
      return;
    }
  }

  if (!context.mounted) return;
  Navigator.of(context).popUntil((route) => route.isFirst);
}
