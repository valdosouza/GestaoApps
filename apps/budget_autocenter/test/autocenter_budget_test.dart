import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/autocenter_budget.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/vehicle_region.dart';
import 'package:budget_autocenter/src/features/budget/presentation/widget/vehicle_inspection.dart';
import 'package:budget_autocenter/src/features/budget/presentation/page/autocenter_budget_page.dart';

void main() {
  test('preserva as 22 posições e os quatro estados do Delphi', () {
    expect(
      carRegions.map((r) => r.id),
      orderedEquals(List.generate(22, (i) => i + 1)),
    );
    for (var index = 0; index < 22; index++) {
      for (final state in InspectionState.values) {
        final inspection = VehicleInspection();
        expect(inspection.serialize(), isNull);
        inspection.regions[index] = state;
        inspection.confirmRemainingNormal();
        final value = inspection.serialize()!;
        expect(value.length, 22);
        expect(value[index], state.code);
        final restored = VehicleInspection()..load(value);
        expect(restored.serialize(), value);
      }
    }
    final mixed = VehicleInspection()..load('NRQA' * 5 + 'NR');
    expect(() => mixed.load('X' * 22), throwsFormatException);
    expect(() => mixed.load('N' * 21), throwsFormatException);
    expect(mixed.serialize(), 'NRQA' * 5 + 'NR');
  });
  test('valores e cópia do rascunho ficam isolados', () {
    final b = AutoCenterBudget()
      ..items.addAll([
        AutoCenterBudgetItem('Peça', 10010, quantity: 2),
        AutoCenterBudgetItem('Serviço', 5000, service: true),
      ])
      ..freight = 1500
      ..discount = 1000;
    expect(b.total, 25520);
    final copy = b.copy()..customer = 'Outro cliente';
    copy.items.first.quantity = 7;
    copy.inspection.regions[0] = InspectionState.dented;
    expect(b.items.first.quantity, 2);
    expect(b.inspection.regions.first, isNull);
    expect(b.customer, isEmpty);
    expect(parseMoney('1.234,56'), 123456);
    expect(money(123456), 'R\$ 1.234,56');
  });
  testWidgets('todas as regiões vetoriais têm área clicável', (tester) async {
    for (final region in carRegions) {
      expect(
        regionPath(region.svg).contains(Offset(region.x, region.y)),
        isTrue,
        reason: 'região ${region.id}',
      );
    }
  });
  for (final width in [320.0, 1000.0]) {
    testWidgets('lista abre detalhes, edita e filtra em largura $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
          home: const AutoCenterBudgetPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('budget-DEMO-001')));
      await tester.pumpAndSettle();
      expect(find.text('Dados do orçamento'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      await tester.tap(find.byKey(const Key('edit-budget')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome do cliente'),
        'Cliente atualizado',
      );
      await tester.tap(find.byKey(const Key('save-draft')));
      await tester.pumpAndSettle();
      expect(find.text('Cliente atualizado'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Cliente atualizado'), findsOneWidget);
      expect(find.byKey(const ValueKey('budget-DEMO-001')), findsOneWidget);
      await tester.tap(find.byTooltip('Filtros'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Placa'),
        'DEF4G56',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Buscar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('budget-DEMO-002')), findsOneWidget);
      expect(find.byKey(const ValueKey('budget-DEMO-001')), findsNothing);
      await tester.tap(find.text('Limpar'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('budget-DEMO-001')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets(
      'fluxo de rascunho, peças, serviço e inspeção em largura $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1100);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
            home: const AutoCenterBudgetPage(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('new-budget')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome do cliente'),
          'Cliente teste',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Adicionar peça'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Adicionar peça'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pneu 175/65 R14'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Adicionar serviço'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Adicionar serviço'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Alinhamento'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('step-1')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Placa (sem hífen)'),
          'ABC1D23',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Marca e modelo'),
          'Hatch teste',
        );
        await tester.tap(find.byKey(const ValueKey('step-2')));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Amassado').last);
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ChoiceChip, 'Amassado'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text('Confirmar restantes como normais'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Confirmar restantes como normais'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sim, estão normais'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('step-3')));
        await tester.pumpAndSettle();
        expect(find.text('Hatch teste'), findsOneWidget);
        expect(find.text('22/22 conferidas · 1 com avarias'), findsOneWidget);
        await tester.tap(find.byKey(const Key('save-draft')));
        await tester.pumpAndSettle();
        expect(find.text('Cliente teste'), findsOneWidget);
        expect(find.text('DEMO-004'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
