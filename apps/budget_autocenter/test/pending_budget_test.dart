import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_autocenter/src/features/budget/data/repository/pending_budget_store.dart';

import 'package:budget_autocenter/src/features/budget/presentation/page/real_budget_list_page.dart';
import 'real_budget_list_test.dart' show FakeReader;
import 'budget_draft_test.dart' show FakeWriter, customer, payment;

void main() {
  setUp(
    () => SharedPreferences.setMockInitialValues({
      'server_ip': '127.0.0.1',
      'tb_institution_id': '7',
      'tb_user_id': 3,
      'token': 'teste',
      'salesman_id': 9,
    }),
  );
  Future<PendingBudget> seeded(
    PendingBudgetStore store, {
    bool review = false,
  }) async {
    final d = await store.allocate(DateTime(2026, 11, 2));
    final value = PendingBudget(
      id: d.id,
      sequence: d.sequence,
      date: d.date,
      customer: customer,
      payment: payment,
      contact: 'Telefone preservado',
      terms: 'À vista',
      review: review,
    );
    await store.put(value);
    return value;
  }

  test(
    'persistência reabre, separa usuário, loja, servidor e não perde outros rascunhos',
    () async {
      var store = await PreferencesPendingBudgetStore.open();
      final a = await seeded(store), b = await seeded(store);
      store = await PreferencesPendingBudgetStore.open();
      expect((await store.all()).map((d) => d.id), [b.id, a.id]);
      expect((await store.all()).first.contact, 'Telefone preservado');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tb_user_id', 4);
      expect(await (await PreferencesPendingBudgetStore.open()).all(), isEmpty);
      await prefs.setInt('tb_user_id', 3);
      await prefs.setString('tb_institution_id', '8');
      expect(await (await PreferencesPendingBudgetStore.open()).all(), isEmpty);
      await prefs.setString('tb_institution_id', '7');
      await prefs.setString('server_ip', '192.168.0.2');
      expect(await (await PreferencesPendingBudgetStore.open()).all(), isEmpty);
      await prefs.setString('server_ip', '127.0.0.1');
      store = await PreferencesPendingBudgetStore.open();
      await store.remove(a.id);
      expect((await store.all()).single.id, b.id);
    },
  );
  test(
    'confirmação remota não volta aos pendentes mesmo antes da remoção',
    () async {
      final store = await PreferencesPendingBudgetStore.open(),
          d = await seeded(await PreferencesPendingBudgetStore.open());
      await store.put(
        PendingBudget(
          id: d.id,
          sequence: d.sequence,
          date: d.date,
          remoteId: 99,
          review: true,
        ),
      );
      expect(await (await PreferencesPendingBudgetStore.open()).all(), isEmpty);
    },
  );
  for (final width in [320.0, 1000.0]) {
    testWidgets(
      'digitar, sair, reconstruir o app e retomar pendente em $width',
      (t) async {
        t.view.physicalSize = Size(width, 1000);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final writer = FakeWriter();
        final store = await PreferencesPendingBudgetStore.open();
        await t.pumpWidget(
          MaterialApp(
            home: RealBudgetListPage(
              reader: FakeReader(),
              writer: writer,
              store: store,
            ),
          ),
        );
        await t.pumpAndSettle();
        await t.tap(find.text('Novo'));
        await t.pumpAndSettle();
        final field = find.widgetWithText(TextFormField, 'Contato');
        await t.ensureVisible(field);
        await t.enterText(field, 'Contato sem cliente');
        // Volta imediatamente, sem aguardar um debounce.
        await t.tap(find.byType(BackButton));
        await t.pumpAndSettle();
        expect(writer.saves, 0);
        expect(find.text('Rascunhos pendentes (1)'), findsOneWidget);
        expect(find.text('PENDENTE'), findsOneWidget);
        await t.pumpWidget(const SizedBox.shrink());
        await t.pumpAndSettle();
        final reopened = await PreferencesPendingBudgetStore.open();
        final saved = (await reopened.all()).single;
        expect(saved.contact, 'Contato sem cliente');
        expect(saved.customer, isNull);
        await t.pumpWidget(
          MaterialApp(
            home: RealBudgetListPage(
              reader: FakeReader(),
              writer: writer,
              store: reopened,
            ),
          ),
        );
        await t.pumpAndSettle();
        await t.tap(find.byKey(ValueKey('pending-budget-' + saved.id)));
        await t.pumpAndSettle();
        expect(find.text('Contato sem cliente'), findsOneWidget);
        expect(writer.saves, 0);
        await t.tap(find.byTooltip('Descartar rascunho local'));
        await t.pumpAndSettle();
        await t.tap(find.text('Descartar'));
        await t.pumpAndSettle();
        expect(await reopened.all(), isEmpty);
        expect(writer.saves, 0);
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets('envio incerto permanece bloqueado após reconstruir e reabrir', (
    t,
  ) async {
    final store = await PreferencesPendingBudgetStore.open();
    final initial = await seeded(store);
    final writer = FakeWriter()..uncertain = true;
    await t.pumpWidget(
      MaterialApp(
        home: RealBudgetListPage(
          reader: FakeReader(),
          writer: writer,
          store: store,
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.byKey(ValueKey('pending-budget-' + initial.id)));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Salvar rascunho'));
    await t.tap(find.text('Salvar rascunho'));
    await t.pumpAndSettle();
    await t.tap(find.text('Criar rascunho'));
    await t.pumpAndSettle();
    expect(writer.saves, 1);
    expect((await store.all()).single.review, isTrue);
    await t.pumpWidget(const SizedBox.shrink());
    await t.pumpAndSettle();
    final reopened = await PreferencesPendingBudgetStore.open();
    await t.pumpWidget(
      MaterialApp(
        home: RealBudgetListPage(
          reader: FakeReader(),
          writer: writer,
          store: reopened,
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('CONFERIR ENVIO'), findsOneWidget);
    await t.tap(find.byKey(ValueKey('pending-budget-' + initial.id)));
    await t.pumpAndSettle();
    final button = t.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Salvar rascunho'),
    );
    expect(button.onPressed, isNull);
    expect(writer.saves, 1);
    expect(t.takeException(), isNull);
  });
  testWidgets('envio confirmado remove pendente e atualiza a lista', (t) async {
    final store = await PreferencesPendingBudgetStore.open();
    final initial = await seeded(store);
    final reader = FakeReader(), writer = FakeWriter();
    await t.pumpWidget(
      MaterialApp(
        home: RealBudgetListPage(reader: reader, writer: writer, store: store),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.byKey(ValueKey('pending-budget-' + initial.id)));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Salvar rascunho'));
    await t.tap(find.text('Salvar rascunho'));
    await t.pumpAndSettle();
    await t.tap(find.text('Criar rascunho'));
    await t.pumpAndSettle();
    expect(writer.saves, 1);
    expect(await store.all(), isEmpty);
    expect(find.text('PENDENTE'), findsNothing);
    expect(reader.calls, [0, 0]);
    expect(t.takeException(), isNull);
  });
}
