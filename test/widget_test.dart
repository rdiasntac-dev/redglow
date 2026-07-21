import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redglow/app.dart';

Future<void> _openClientDemo(WidgetTester tester) async {
  await tester.pumpWidget(const RedGlowApp());
  await tester.pump();
  await tester.ensureVisible(find.byKey(const Key('demo-access')));
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
    expect(find.text('Acessar demonstração como Cliente'), findsOneWidget);
  });

  testWidgets('home shows the approved REDGLOW V7 content', (tester) async {
    await _openClientDemo(tester);

    expect(find.text('REDGLOW PONTOS'), findsOneWidget);
    expect(find.text('R. Izabel A Redentora, 1000'), findsOneWidget);
    expect(find.text('Lari (Manicure)'), findsOneWidget);
    expect(find.text('R\$ 60,00'), findsOneWidget);
  });

  testWidgets('Lari opens the order confirmation flow', (tester) async {
    await _openClientDemo(tester);

    await tester.ensureVisible(find.text('Lari (Manicure)').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lari (Manicure)').last);
    await tester.pumpAndSettle();

    expect(find.text('Tudo certo para agendar!'), findsOneWidget);
    expect(find.text('Confirmar e Chamar Prestadora'), findsOneWidget);
  });

  testWidgets('identity verification starts from its CTA', (tester) async {
    await _openClientDemo(tester);

    await tester.ensureVisible(find.text('Verificar Identidade'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verificar Identidade'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('start-verification')));
    await tester.pump();

    expect(find.text('Segurança REDGLOW'), findsOneWidget);
    expect(find.byKey(const Key('cpf-field')), findsOneWidget);
    expect(find.byKey(const Key('phone-field')), findsOneWidget);
  });

  testWidgets('provider demo opens the provider dashboard', (tester) async {
    await tester.pumpWidget(const RedGlowApp());
    await tester.pump();

    await tester.tap(find.byKey(const Key('provider-role')));
    await tester.ensureVisible(find.byKey(const Key('demo-access')));
    await tester.tap(find.byKey(const Key('demo-access')));
    await tester.pumpAndSettle();

    expect(find.text('MODO PRESTADORA'), findsOneWidget);
    expect(find.text('GANHOS DE HOJE'), findsOneWidget);
  });
}
