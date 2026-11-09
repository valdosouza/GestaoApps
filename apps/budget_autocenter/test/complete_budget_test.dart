import 'package:budget_autocenter/src/features/budget/data/repository/budget_draft_repository.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_autocenter/src/features/budget/data/repository/complete_budget_repository.dart';
import 'package:budget_autocenter/src/features/budget/data/repository/pending_budget_store.dart';

import 'package:budget_autocenter/src/features/budget/domain/entity/autocenter_budget.dart';
import 'package:budget_autocenter/src/features/budget/presentation/page/new_budget_page.dart';
import 'package:budget_autocenter/src/features/budget/presentation/page/budget_details_page.dart';
import 'budget_draft_test.dart' show FakeWriter, customer, payment;

Map<String, dynamic> fixture() => {
  'version': 'original',
  'editable': true,
  'header': {
    'id': 99,
    'number': 'ORC-99',
    'institutionId': 7,
    'date': '2026-11-02',
    'customerId': customer.id,
    'customerName': customer.label,
    'paymentTypeId': payment.id,
    'paymentLabel': payment.label,
    'contact': 'Contato',
    'paymentTerms': 'À vista',
    'freight': 0,
    'additional': 0,
    'notes': 'Observação real',
    'total': 45,
  },
  'items': [
    {
      'id': 1,
      'type': 'P',
      'productId': 2,
      'description': 'Peça real',
      'quantity': 1.5,
      'unitPrice': 10,
      'discountValue': 0,
      'stockId': 1,
      'priceListId': 1,
    },
    {
      'id': 2,
      'type': 'S',
      'productId': 3,
      'description': 'Serviço real',
      'quantity': 1,
      'unitPrice': 30,
      'discountValue': 0,
      'stockId': 0,
      'priceListId': 0,
    },
  ],
  'vehicle': {
    'plate': 'ABC1D23',
    'brandId': 1,
    'modelId': 2,
    'kindId': 1,
    'colorId': 1,
    'year': '2020',
    'engine': 1600,
    'km': '10000',
    'fleet': '',
    'notes': 'Motor',
    'chassis': 'Chassi',
    'exitDate': '',
    'exitHour': '',
  },
  'checklist': {
    'regions': '${'N' * 21}A',
    'frontTyre': 'E',
    'backTyre': 'B',
    'spareTyre': 'R',
    'fuel': '3',
    'valves': '16',
    '_confirmed': true,
    'km': '10001',
    'notes': 'Inspeção',
    'entryDate': '02/11/2026',
    'entryHour': '10:30',
    'prism': '10',
    for (final k in accessoryNames.keys) k: 'N',
  },
};

class CompleteFake extends FakeWriter implements CompleteBudgetWriter {
  @override
  Future<Map<String, dynamic>> createCatalog(
    String kind,
    String label, {
    Map<String, String> parameters = const {},
  }) async => {'id': 10, 'label': label};
  Map<String, dynamic>? submitted;
  bool conflict = false;
  @override
  Future<Map<String, dynamic>> loadDocument(int id) async => fixture();
  @override
  Future<Map<String, dynamic>> saveDocument(
    Map<String, dynamic> d,
    String operationId,
  ) async {
    submitted = Map<String, dynamic>.from(jsonDecode(jsonEncode(d)) as Map);
    saves++;
    if (conflict) throw StateError('O orçamento mudou no ERP.');
    return fixture();
  }

  @override
  Future<int?> findOperation(String operationId) async => 99;
  @override
  Future<CatalogPage> catalog(
    String kind, {
    String search = '',
    int offset = 0,
    Map<String, String> parameters = const {},
  }) async => CatalogPage(
    [
      {
        'id': kind == 'products' ? 4 : 1,
        'label': kind == 'products' ? 'Nova peça' : 'Cadastro real',
        'price': 12.5,
      },
    ],
    1,
    0,
  );
}

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
  test(
    'HTTP carrega documento e envia atualização atômica com versão e chave estável',
    () async {
      final requests = <http.Request>[];
      final api = CompleteBudgetRepository(
        client: MockClient((r) async {
          requests.add(r);
          expect(r.headers['Authorization'], 'Bearer teste');
          expect(r.url.path, '/api/v1/autocenter/budgets/99');
          if (r.method == 'PUT') {
            final body = jsonDecode(r.body);
            expect(body['operationId'], 'request_123456');
            expect(body['institutionId'], 7);
            expect(body['document']['version'], 'original');
            expect(body['document']['items'][0]['quantity'], 1.5);
            expect(body['document']['checklist']['regions'], '${'N' * 21}A');
          }
          return http.Response(jsonEncode(fixture()), 200);
        }),
      );
      final d = await api.loadDocument(99);
      await api.saveDocument(d, 'request_123456');
      expect(requests.length, 2);
      api.close();
    },
  );
  test(
    'conflito é recuperável e consulta de envio não cria orçamento',
    () async {
      final api = CompleteBudgetRepository(
        client: MockClient((r) async {
          if (r.method == 'GET') return http.Response('{"id":99}', 200);
          return http.Response('{"error":"Alterado no ERP"}', 409);
        }),
      );
      await expectLater(
        api.saveDocument(fixture(), 'request_123456'),
        throwsStateError,
      );
      expect(await api.findOperation('request_123456'), 99);
      api.close();
    },
  );
  for (final width in [320.0, 1000.0]) {
    testWidgets(
      'abre detalhes, edita peça e serviço, envia checklist preservado em $width',
      (t) async {
        t.view.physicalSize = Size(width, 1000);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final store = await PreferencesPendingBudgetStore.open(),
            writer = CompleteFake();
        await t.pumpWidget(
          MaterialApp(
            home: BudgetDetailsPage(id: 99, store: store, writer: writer),
          ),
        );
        await t.pumpAndSettle();
        expect(find.text(customer.label), findsOneWidget);
        await t.tap(find.text('Editar orçamento'));
        await t.pumpAndSettle();
        await t.ensureVisible(find.text('Peças e mão de obra'));
        await t.tap(find.text('Peças e mão de obra'));
        await t.pumpAndSettle();
        await t.ensureVisible(find.text('Peça real'));
        await t.tap(find.text('Peça real'));
        await t.pumpAndSettle();
        await t.enterText(
          find.widgetWithText(TextFormField, 'Quantidade'),
          '2,25',
        );
        await t.tap(find.text('Aplicar'));
        await t.pumpAndSettle();
        expect(
          (await store.all()).single.document['items'][0]['quantity'],
          2.25,
        );
        await t.ensureVisible(find.text('Adicionar peça'));
        await t.tap(find.text('Adicionar peça'));
        await t.pumpAndSettle();
        await t.tap(find.text('Nova peça'));
        await t.pumpAndSettle();
        await t.tap(find.text('Cadastro real'));
        await t.pumpAndSettle();
        await t.tap(find.text('Cadastro real'));
        await t.pumpAndSettle();
        await t.tap(find.text('Aplicar'));
        await t.pumpAndSettle();
        await t.ensureVisible(find.text('Salvar rascunho'));
        await t.tap(find.text('Salvar rascunho'));
        await t.pumpAndSettle();
        expect(find.text('Salvar alterações no ERP?'), findsOneWidget);
        await t.tap(find.text('Confirmar alterações'));
        await t.pumpAndSettle();
        expect(writer.saves, 1);
        expect(writer.submitted!['items'].length, 3);
        expect(writer.submitted!['checklist']['regions'], '${'N' * 21}A');
        expect(writer.submitted!['vehicle']['plate'], 'ABC1D23');
        expect(await store.all(), isEmpty);
        expect(t.takeException(), isNull);
      },
    );
  }
  for (final regions in ['', '${'_' * 21}A']) {
    testWidgets(
      'salvar completa regiões pendentes preservando avarias $regions',
      (t) async {
        final store = await PreferencesPendingBudgetStore.open();
        final writer = CompleteFake();
        final seed = await store.allocate(DateTime(2026, 11, 2));
        final document = fixture();
        document['checklistDirty'] = true;
        document['checklist']['regions'] = regions;
        final draft = PendingBudget(
          id: seed.id,
          sequence: seed.sequence,
          date: seed.date,
          customer: customer,
          payment: payment,
          document: document,
        );
        await t.pumpWidget(
          MaterialApp(
            home: NewBudgetPage(
              store: store,
              writer: writer,
              initialDraft: draft,
            ),
          ),
        );
        await t.pumpAndSettle();
        await t.ensureVisible(find.text('Salvar rascunho'));
        await t.tap(find.text('Salvar rascunho'));
        await t.pumpAndSettle();
        await t.tap(find.text('Confirmar alterações'));
        await t.pumpAndSettle();
        expect(
          writer.submitted!['checklist']['regions'],
          regions.isEmpty ? 'N' * 22 : '${'N' * 21}A',
        );
        expect(await store.all(), isEmpty);
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets('conflito mantém todos os dados pendentes e a versão original', (
    t,
  ) async {
    final store = await PreferencesPendingBudgetStore.open(),
        writer = CompleteFake()..conflict = true;
    final seed = await store.allocate(DateTime(2026, 11, 2));
    final draft = PendingBudget(
      id: seed.id,
      sequence: seed.sequence,
      date: seed.date,
      customer: customer,
      payment: payment,
      document: fixture(),
    );
    await t.pumpWidget(
      MaterialApp(
        home: NewBudgetPage(store: store, writer: writer, initialDraft: draft),
      ),
    );
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Salvar rascunho'));
    await t.tap(find.text('Salvar rascunho'));
    await t.pumpAndSettle();
    await t.tap(find.text('Confirmar alterações'));
    await t.pumpAndSettle();
    final saved = (await store.all()).single;
    expect(saved.review, isFalse);
    expect(saved.document['version'], 'original');
    expect(saved.document['items'].length, 2);
    expect(saved.document['checklist']['regions'], '${'N' * 21}A');
    expect(find.text('O orçamento mudou no ERP.'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('repete envio incerto com a mesma chave sem perder o documento', (
    t,
  ) async {
    final store = await PreferencesPendingBudgetStore.open(),
        writer = RetryComplete();
    final seed = await store.allocate(DateTime(2026, 11, 2));
    final draft = PendingBudget(
      id: seed.id,
      sequence: seed.sequence,
      date: seed.date,
      customer: customer,
      payment: payment,
      document: fixture(),
    );
    await t.pumpWidget(
      MaterialApp(
        home: NewBudgetPage(store: store, writer: writer, initialDraft: draft),
      ),
    );
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Salvar rascunho'));
    await t.tap(find.text('Salvar rascunho'));
    await t.pumpAndSettle();
    await t.tap(find.text('Confirmar alterações'));
    await t.pumpAndSettle();
    expect((await store.all()).single.review, isTrue);
    await t.ensureVisible(find.text('Repetir o mesmo envio'));
    await t.tap(find.text('Repetir o mesmo envio'));
    await t.pumpAndSettle();
    await t.tap(find.text('Confirmar alterações'));
    await t.pumpAndSettle();
    expect(writer.keys.length, 2);
    expect(writer.keys.toSet().length, 1);
    expect(await store.all(), isEmpty);
    expect(t.takeException(), isNull);
  });
  testWidgets('pendente incerto antigo não é reenviado no protocolo novo', (
    t,
  ) async {
    final store = await PreferencesPendingBudgetStore.open(),
        writer = CompleteFake();
    final seed = await store.allocate(DateTime(2026, 11, 2));
    final draft = PendingBudget(
      id: seed.id,
      sequence: seed.sequence,
      date: seed.date,
      customer: customer,
      payment: payment,
      review: true,
    );
    await t.pumpWidget(
      MaterialApp(
        home: NewBudgetPage(store: store, writer: writer, initialDraft: draft),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('Repetir o mesmo envio'), findsNothing);
    expect(find.text('Conferir envio no servidor'), findsNothing);
    expect(writer.saves, 0);
  });
}

class RetryComplete extends CompleteFake {
  final keys = <String>[];
  @override
  Future<Map<String, dynamic>> saveDocument(
    Map<String, dynamic> doc,
    String key,
  ) async {
    keys.add(key);
    if (keys.length == 1) throw BudgetSaveUncertain();
    return super.saveDocument(doc, key);
  }
}
