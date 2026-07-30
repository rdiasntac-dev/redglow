import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redglow/app.dart';
import 'package:redglow/models/user_role.dart';
import 'package:redglow/screens/edit_profile_screen.dart';
import 'package:redglow/screens/focused_explore_screen.dart';
import 'package:redglow/screens/identity_verification_screen.dart';
import 'package:redglow/screens/provider_analytics_screen.dart';
import 'package:redglow/screens/provider_services_screen.dart';
import 'package:redglow/screens/rating_screen.dart';
import 'package:redglow/services/firebase_marketplace_service.dart';
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

Future<void> _openProviderDemo(WidgetTester tester) async {
  await tester.pumpWidget(const RedGlowApp());
  await tester.pump();
  await tester.tap(find.byKey(const Key('provider-role')));
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

  testWidgets('client home shows the approved REDGLOW content', (tester) async {
    await _openClientDemo(tester);

    expect(find.text('REDGLOW PONTOS'), findsOneWidget);
    expect(find.text('R. Izabel A Redentora, 1000'), findsOneWidget);

    await _scrollTo(tester, find.text('Lari (Manicure)'));
    expect(find.text('Lari (Manicure)'), findsOneWidget);
    expect(find.text('R\$ 60,00'), findsOneWidget);
  });

  testWidgets('client search exposes every niche and its subsections',
      (tester) async {
    await _openClientDemo(tester);

    await tester.tap(find.byIcon(Icons.search_rounded).last);
    await tester.pumpAndSettle();

    expect(find.byType(FocusedExploreScreen), findsOneWidget);
    expect(find.text('Manicure'), findsWidgets);
    expect(find.text('Pedicure'), findsWidgets);
    expect(find.text('Nail Designer'), findsWidgets);
    expect(find.text('Maquiadora'), findsWidgets);
    expect(find.text('Designer de Sobrancelhas'), findsWidgets);
    expect(find.text('Lash Designer'), findsWidgets);

    final nailDesigner = find.text('Nail Designer').first;
    await tester.ensureVisible(nailDesigner);
    await tester.pumpAndSettle();
    await tester.tap(nailDesigner);
    await tester.pumpAndSettle();

    expect(find.text('Alongamento em gel'), findsWidgets);
    expect(find.text('Alongamento em fibra'), findsWidgets);
    expect(find.text('Blindagem'), findsWidgets);
    expect(find.text('Manutenção'), findsWidgets);
  });

  testWidgets('Lari opens the order confirmation flow', (tester) async {
    await _openClientDemo(tester);

    await _scrollTo(tester, find.text('Lari (Manicure)'));
    await tester.tap(find.text('Lari (Manicure)').last);
    await tester.pumpAndSettle();

    expect(find.text('Tudo certo para agendar!'), findsOneWidget);
    expect(find.text('Confirmar e Chamar Prestadora'), findsOneWidget);
    expect(find.text('BETA · SEM COBRANÇA'), findsOneWidget);

    await _scrollTo(tester, find.byKey(const Key('confirm-order')));
    await tester.tap(find.byKey(const Key('confirm-order')));
    await tester.pump();

    expect(find.text('Fechar e Aguardar Aceite'), findsOneWidget);
  });

  testWidgets('selected service reaches the order confirmation',
      (tester) async {
    await _openClientDemo(tester);

    await tester.tap(find.byIcon(Icons.search_rounded).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('niche-manicure')));
    await tester.pumpAndSettle();
    final serviceChip = find.byKey(const Key('service-spa das mãos'));
    await tester.ensureVisible(serviceChip);
    await tester.tap(serviceChip);
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text('Lari (Manicure)'));
    await tester.tap(find.text('Lari (Manicure)').last);
    await tester.pumpAndSettle();

    expect(find.text('Spa das mãos'), findsOneWidget);
    expect(find.text('BETA · SEM COBRANÇA'), findsOneWidget);
  });

  testWidgets('client account protects the system back action', (tester) async {
    await _openClientDemo(tester);

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(
      find.text('Para encerrar com segurança, use “Sair da conta”.'),
      findsOneWidget,
    );
  });

  testWidgets('provider dashboard has no fake appointment list',
      (tester) async {
    await _openProviderDemo(tester);

    expect(find.text('PAINEL PROFISSIONAL'), findsOneWidget);
    expect(find.byKey(const Key('provider-home-avatar')), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Pausada'), findsNothing);
    await tester.tap(find.byIcon(Icons.person_rounded).last);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('provider-services-profile')), findsOneWidget);
    expect(find.text('Amanda Souza'), findsNothing);
    expect(find.text('Priscila Matos'), findsNothing);
    expect(find.text('Renata Campos'), findsNothing);
    expect(find.byKey(const Key('provider-emergency-action')), findsOneWidget);
  });

  testWidgets('provider dashboard uses a single analytics entry',
      (tester) async {
    await _openProviderDemo(tester);

    final dashboard = find.byKey(const Key('provider-main-dashboard'));
    await _scrollTo(tester, dashboard);
    expect(dashboard, findsOneWidget);
    expect(find.text('Painel de atendimentos'), findsOneWidget);

    await tester.tap(dashboard);
    await tester.pumpAndSettle();

    expect(find.byType(ProviderAnalyticsScreen), findsOneWidget);
    expect(find.byKey(const Key('provider-analytics-chart')), findsOneWidget);
  });

  testWidgets('provider can choose the services actually offered',
      (tester) async {
    await _openProviderDemo(tester);

    await tester.tap(find.byIcon(Icons.person_rounded).last);
    await tester.pumpAndSettle();
    final servicesEntry = find.byKey(const Key('provider-services-profile'));
    await _scrollTo(tester, servicesEntry);
    await tester.tap(servicesEntry);
    await tester.pumpAndSettle();

    expect(find.byType(ProviderServicesScreen), findsOneWidget);
    expect(find.text('Serviços que realizo'), findsOneWidget);
    expect(find.text('Manicure tradicional'), findsOneWidget);
    expect(find.text('Esmaltação em gel'), findsOneWidget);
    expect(find.byKey(const Key('save-provider-services')), findsOneWidget);
  });

  testWidgets('provider can log out of the demonstrative account',
      (tester) async {
    await _openProviderDemo(tester);

    await tester.tap(find.byIcon(Icons.person_rounded).last);
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.byKey(const Key('provider-logout')));
    await tester.tap(find.byKey(const Key('provider-logout')));
    await tester.pumpAndSettle();

    expect(find.text('Acessar demonstração como Prestadora'), findsOneWidget);
  });

  testWidgets('identity verification can be started', (tester) async {
    final state = DemoAppState();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      DemoAppScope(
        controller: state,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const IdentityVerificationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('start-verification')), findsOneWidget);
    await tester.tap(find.byKey(const Key('start-verification')));
    await tester.pump();
    expect(find.text('Continuar Verificação'), findsOneWidget);
  });

  testWidgets('profile editor exposes professional fields', (tester) async {
    final state = DemoAppState();
    addTearDown(state.dispose);
    await tester.pumpWidget(
      DemoAppScope(
        controller: state,
        child: MaterialApp(
          theme: AppTheme.dark,
          home: const EditProfileScreen(role: UserRole.provider),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-name-field')), findsOneWidget);
    expect(find.byKey(const Key('profile-specialty-field')), findsOneWidget);
    expect(find.byKey(const Key('profile-price-field')), findsOneWidget);
  });

  testWidgets('rating form remains visible on a desktop viewport',
      (tester) async {
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

    expect(find.byKey(const Key('rating-star-1')), findsOneWidget);
    expect(find.byKey(const Key('rating-comment')), findsOneWidget);
    expect(find.byKey(const Key('submit-rating')), findsOneWidget);
  });

  testWidgets('emergency action requires choosing a public service',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          floatingActionButton: EmergencyFloatingButton(
            key: Key('client-emergency-action'),
          ),
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

    state.selectRole(UserRole.client);
    await state.submitRating(5);
    expect(state.clientToProviderRating, 5);
    expect(state.bookingStatus, DemoBookingStatus.reviewed);
    expect(state.points, 2540);

    state.dispose();
  });

  test('cancellation stores a reason and never charges in the beta', () async {
    final state = DemoAppState();
    await state.requestBooking();
    final succeeded = await state.cancelBooking(
      reason: 'Horário não serve mais',
    );

    expect(succeeded, isTrue);
    expect(state.bookingStatus, DemoBookingStatus.cancelled);
    expect(state.lastCancellationReason, 'Horário não serve mais');
    expect(state.simulatedCancellationFeeCents, 0);

    state.dispose();
  });

  test('provider services persist in the demonstrative profile', () async {
    final state = DemoAppState()..selectRole(UserRole.provider);

    final updated = await state.updateProviderServices(
      specialties: const ['Pedicure'],
      services: const ['Spa dos pés', 'Pedicure tradicional'],
    );

    expect(updated, isTrue);
    expect(state.demoProviderSpecialty, 'Pedicure');
    expect(
      state.demoProviderServices,
      const ['Pedicure tradicional', 'Spa dos pés'],
    );

    state.dispose();
  });

  test('provider can persist more than one niche and matching services',
      () async {
    final state = DemoAppState()..selectRole(UserRole.provider);

    final updated = await state.updateProviderServices(
      specialties: const ['Manicure', 'Pedicure'],
      services: const [
        'Manicure tradicional',
        'Pedicure tradicional',
      ],
    );

    expect(updated, isTrue);
    expect(state.providerSpecialties, const ['Manicure', 'Pedicure']);
    expect(
      state.providerServices,
      const ['Manicure tradicional', 'Pedicure tradicional'],
    );

    state.dispose();
  });

  test('selected service is preserved for the booking', () {
    final state = DemoAppState();
    final professional = MarketplaceProfessional(
      uid: 'demo-lari',
      name: 'Lari (Manicure)',
      specialty: 'Manicure',
      specialties: const ['Manicure'],
      priceCents: 6000,
      rating: 4.9,
      services: const ['Manicure tradicional', 'Spa das mãos'],
      isOnline: true,
    );

    state.selectProfessional(
      professional,
      serviceName: 'Spa das mãos',
    );

    expect(state.selectedService, 'Spa das mãos');
    state.dispose();
  });

  test('points remain simulated and real sessions cannot redeem locally', () {
    final state = DemoAppState();

    state.points = DemoAppState.pointsRedemptionCost;
    expect(state.redeemPoints(), isTrue);
    expect(state.points, 0);

    state.isDemoSession = false;
    state.points = DemoAppState.pointsRedemptionCost;
    expect(state.redeemPoints(), isFalse);
    expect(state.points, DemoAppState.pointsRedemptionCost);

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
