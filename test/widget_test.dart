import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redglow/app.dart';
import 'package:redglow/models/user_role.dart';
import 'package:redglow/screens/identity_verification_screen.dart';
import 'package:redglow/state/demo_app_state.dart';
import 'package:redglow/theme/app_theme.dart';

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    260,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _openClientDemo(WidgetTester tester) async {
  await tester.pumpWidget(const RedGlowApp());
  await tester.pump();
  await _scrollTo(tester, find.byKey(const Key('demo-access')));
  await tester.tap(find.byKey(const Key('demo-access')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('auth offers client and provider access', (tester) async {
    await tester.pumpWidget(const RedGlowApp());
    await tester.pump();

    expect(find.text('REDGLOW'), findsOneWidget);
    expect(find.text('Cliente'), findsOneWidget);
    expect(find.text('Prestadora'), findsOneWidget);

    await _scrollTo(tester, find.byKey(const Key('demo-access')));
    expect(find.text('Acessar demonstração como Cliente'), findsOneWidget);
  });

  testWidgets('home shows the approved REDGLOW V7 content', (tester) async {
    await _openClientDemo(tester);

    expect(find.text('REDGLOW PONTOS'), findsOneWidget);
    expect(find.text('R. Izabel A Redentora, 1000'), findsOneWidget);

    await _scrollTo(tester, find.text('Lari (Manicure)'));
    expect(find.text('Lari (Manicure)'), findsOneWidget);
    expect(find.text('R\$ 60,00'), findsOneWidget);
    expect(find.text('Área da Prestadora'), findsNothing);
    expect(find.text('Plano Profissional'), findsNothing);
  });

  testWidgets('Lari opens the order confirmation flow', (tester) async {
    await _openClientDemo(tester);

    await _scrollTo(tester, find.text('Lari (Manicure)'));
    await tester.tap(find.text('Lari (Manicure)').last);
    await tester.pumpAndSettle();

    expect(find.text('Tudo certo para agendar!'), findsOneWidget);
    expect(find.text('Confirmar e Chamar Prestadora'), findsOneWidget);

    await _scrollTo(tester, find.byKey(const Key('confirm-order')));
    await tester.tap(find.byKey(const Key('confirm-order')));
    await tester.pump();

    expect(find.text('Fechar e Aguardar Aceite'), findsOneWidget);
  });

  testWidgets('home offers the identity verification CTA', (tester) async {
    await _openClientDemo(tester);

    final identityEntry = find.byKey(const Key('identity-check-entry'));
    await _scrollTo(tester, identityEntry);
    expect(identityEntry, findsOneWidget);
  });

  testWidgets('identity verification can be started', (tester) async {
    final demoState = DemoAppState();
    await tester.pumpWidget(
      DemoAppScope(
        controller: demoState,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const IdentityVerificationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Segurança REDGLOW'), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-verification')));
    await tester.pump();

    expect(find.text('Continuar Verificação'), findsOneWidget);
    expect(find.byKey(const Key('cpf-field')), findsOneWidget);
    expect(find.byKey(const Key('phone-field')), findsOneWidget);
  });

  testWidgets('provider demo opens the provider dashboard', (tester) async {
    await tester.pumpWidget(const RedGlowApp());
    await tester.pump();

    await tester.tap(find.byKey(const Key('provider-role')));
    await _scrollTo(tester, find.byKey(const Key('demo-access')));
    await tester.tap(find.byKey(const Key('demo-access')));
    await tester.pumpAndSettle();

    expect(find.text('MODO PRESTADORA'), findsOneWidget);
    expect(find.text('Plano profissional'), findsOneWidget);
    expect(find.text('REDGLOW PONTOS'), findsNothing);

    await _scrollTo(tester, find.text('GANHOS DE HOJE'));
    expect(find.text('GANHOS DE HOJE'), findsOneWidget);
  });

  testWidgets('provider can log out of the demonstrative account', (tester) async {
    await tester.pumpWidget(const RedGlowApp());
    await tester.pump();

    await tester.tap(find.byKey(const Key('provider-role')));
    await _scrollTo(tester, find.byKey(const Key('demo-access')));
    await tester.tap(find.byKey(const Key('demo-access')));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.byKey(const Key('provider-logout')));
    await tester.tap(find.byKey(const Key('provider-logout')));
    await tester.pumpAndSettle();

    expect(find.text('Acessar demonstração como Prestadora'), findsOneWidget);
  });

  test('shared demo state follows the bilateral service lifecycle', () {
    final state = DemoAppState();

    state.selectRole(UserRole.client);
    state.requestBooking();
    expect(state.bookingStatus, DemoBookingStatus.requested);

    state.selectRole(UserRole.provider);
    state.acceptBooking();
    state.startTrip();
    state.startService();
    state.completeService();
    state.submitRating(5, asProvider: true);
    expect(state.providerToClientRating, 5);
    expect(state.bookingStatus, DemoBookingStatus.completed);

    state.selectRole(UserRole.client);
    state.submitRating(5);
    expect(state.clientToProviderRating, 5);
    expect(state.bookingStatus, DemoBookingStatus.reviewed);
    expect(state.points, 2540);

    state.dispose();
  });

  test('identity checks remain separate between client and provider', () {
    final state = DemoAppState();

    state.selectRole(UserRole.client);
    state.markIdentityVerified();
    expect(state.identityVerified, isTrue);

    state.selectRole(UserRole.provider);
    expect(state.identityVerified, isFalse);

    state.dispose();
  });
}
