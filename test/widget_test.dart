import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redglow/app.dart';
import 'package:redglow/models/user_role.dart';
import 'package:redglow/screens/identity_verification_screen.dart';
import 'package:redglow/screens/rating_screen.dart';
import 'package:redglow/state/demo_app_state.dart';
import 'package:redglow/theme/app_theme.dart';
import 'package:redglow/widgets/emergency_action.dart';

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

    expect(find.byType(IdentityVerificationScreen), findsOneWidget);
    expect(find.byKey(const Key('start-verification')), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-verification')));
    await tester.pump();

    expect(find.text('Continuar Verificação'), findsOneWidget);
    await _scrollTo(tester, find.byKey(const Key('cpf-field')));
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

  testWidgets('rating form remains visible on a desktop viewport', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1366, 768));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final state = DemoAppState();
    addTearDown(state.dispose);

    await tester.pumpWidget(
      DemoAppScope(
        controller: state,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const RatingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstStar = find.byKey(const Key('rating-star-1'));
    expect(firstStar, findsOneWidget);
    expect(find.byKey(const Key('rating-comment')), findsOneWidget);
    expect(find.byKey(const Key('submit-rating')), findsOneWidget);
    expect(tester.getCenter(firstStar).dy, lessThan(700));
  });

  testWidgets('emergency action requires choosing a public service', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          floatingActionButton: EmergencyFloatingButton(),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('client-emergency-action')));
    await tester.pumpAndSettle();

    expect(find.text('Central de Segurança'), findsOneWidget);
    expect(find.byKey(const Key('emergency-call-190')), findsOneWidget);
    expect(find.byKey(const Key('emergency-call-153')), findsOneWidget);
  });

  test('shared demo state follows the bilateral service lifecycle', () async {
    final state = DemoAppState();

    state.selectRole(UserRole.client);
    await state.requestBooking();
    expect(state.bookingStatus, DemoBookingStatus.requested);

    state.selectRole(UserRole.provider);
    await state.acceptBooking();
    await state.startTrip();
    await state.startService();
    await state.completeService();
    await state.submitRating(5, asProvider: true);
    expect(state.providerToClientRating, 5);
    expect(state.bookingStatus, DemoBookingStatus.completed);

    state.selectRole(UserRole.client);
    await state.submitRating(5);
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

  test('real and demonstrative sessions remain distinguishable', () {
    final state = DemoAppState();

    state.startSession(
      role: UserRole.provider,
      demo: false,
      name: 'Lari REDGLOW',
    );

    expect(state.activeRole, UserRole.provider);
    expect(state.isDemoSession, isFalse);
    expect(state.accountName, 'Lari REDGLOW');
    expect(state.points, 0);

    state.startSession(role: UserRole.client, demo: true);
    expect(state.points, 2480);
    expect(state.bookingStatus, DemoBookingStatus.idle);

    state.dispose();
  });
}
