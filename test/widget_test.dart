import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:redglow/app.dart';

void main() {
  testWidgets('home shows the approved REDGLOW V7 content', (tester) async {
    await tester.pumpWidget(const RedGlowApp());
    await tester.pump();

    expect(find.text('REDGLOW PONTOS'), findsOneWidget);
    expect(find.text('R. Izabel A Redentora, 1000'), findsOneWidget);
    expect(find.text('Lari (Manicure)'), findsOneWidget);
    expect(find.text('R\$ 60,00'), findsOneWidget);
  });

  testWidgets('Lari opens the order confirmation flow', (tester) async {
    await tester.pumpWidget(const RedGlowApp());
    await tester.pump();

    await tester.drag(find.byKey(const Key('home-scroll')), const Offset(0, -1500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lari (Manicure)').last);
    await tester.pumpAndSettle();

    expect(find.text('Tudo certo para agendar!'), findsOneWidget);
    expect(find.text('Confirmar e Chamar Prestadora'), findsOneWidget);
  });

  testWidgets('identity verification starts from its CTA', (tester) async {
    await tester.pumpWidget(const RedGlowApp());
    await tester.pump();

    await tester.drag(find.byKey(const Key('home-scroll')), const Offset(0, -950));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Verificar Identidade'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('start-verification')));
    await tester.pump();

    expect(find.text('Segurança REDGLOW'), findsOneWidget);
    expect(find.byKey(const Key('cpf-field')), findsOneWidget);
    expect(find.byKey(const Key('phone-field')), findsOneWidget);
  });
}
