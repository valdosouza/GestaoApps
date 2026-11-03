import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:core/shared/helpers/local_storage.dart';
import 'package:budget_autocenter/src/features/budget/data/repository/budget_draft_repository.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/budget_list_entry.dart';
import 'package:budget_autocenter/src/features/budget/presentation/page/real_budget_list_page.dart';
import 'package:budget_autocenter/src/features/budget/presentation/page/new_budget_page.dart';
import 'real_budget_list_test.dart' show FakeReader, row;

const customer = BudgetChoice(42, 'Cliente do ERP');
const payment = BudgetChoice(4, 'Dinheiro');

class FakeWriter implements BudgetDraftWriter {
  int saves = 0;
  bool uncertain = false;
  final queries = <String>[];
  Completer<BudgetListEntry>? pending;
  @override
  Future<void> authorize() async {}
  @override
  Future<BudgetChoices> choices({
    required bool customers,
    String search = '',
    int offset = 0,
  }) async {
    queries.add(search);
    return BudgetChoices([customers ? customer : payment], 1, offset);
  }

  @override
  Future<BudgetListEntry> create({
    required BudgetChoice customer,
    required BudgetChoice payment,
    required DateTime date,
    String contact = '',
    String terms = '',
  }) async {
    saves++;
    if (uncertain) throw BudgetSaveUncertain();
    return pending?.future ?? BudgetListEntry.fromJson(row(99));
  }

  @override
  void close() {}
}

void main() {
  setUpAll(() => SharedPreferences.setMockInitialValues({}));
  Future<void> session() async {
    final s = LocalStorageService.instance;
    for (final e in {
      'server_ip': '127.0.0.1',
      'tb_institution_id': '7',
      'token': 'teste',
      'tb_user_id': 3,
      'user_level': '1',
      'salesman_id': 9,
    }.entries) {
      await s.saveItem(key: e.key, value: e.value);
    }
  }

  test('cria somente cabeçalho com sessão e permissão Inserir', () async {
    await session();
    var posts = 0;
    final repo = BudgetDraftRepository(
      client: MockClient((r) async {
        expect(r.headers['Authorization'], 'Bearer teste');
        if (r.url.path.endsWith('/permission/check')) {
          expect(jsonDecode(r.body)['kind'], 'Inserir');
          return http.Response('{"result":true}', 200);
        }
        expect(r.url.path, '/api/v1/budgets');
        expect(r.method, 'POST');
        posts++;
        final j = jsonDecode(r.body) as Map;
        expect(j['customerId'], 42);
        expect(j['customerName'], 'Cliente do ERP');
        expect(j['paymentTypeId'], 4);
        expect(j['institutionId'], 7);
        expect(j['userId'], 3);
        expect(j['salesmanId'], 9);
        expect(j['date'], '2026-11-02');
        expect(j['contact'], 'Contato');
        expect(j['total'], 0);
        expect(j['approved'], 'N');
        expect(j.containsKey('items'), isFalse);
        expect(j.containsKey('number'), isFalse);
        return http.Response(jsonEncode(row(99)), 201);
      }),
    );
    final result = await repo.create(
      customer: customer,
      payment: payment,
      date: DateTime(2026, 11, 2),
      contact: ' Contato ',
    );
    expect(result.id, 99);
    expect(posts, 1);
    repo.close();
  });
  test('busca cadastros com search e paginação, sem gravação', () async {
    await session();
    final repo = BudgetDraftRepository(
      client: MockClient((r) async {
        expect(r.method, 'GET');
        expect(r.url.queryParameters, {
          'limit': '20',
          'offset': '20',
          'search': 'Maria',
        });
        final customers = r.url.path.endsWith('/customers');
        if (!customers) expect(r.url.path.endsWith('/payment-types'), isTrue);
        return http.Response(
          jsonEncode({
            'data': [
              customers
                  ? {'id': 42, 'name': 'Maria'}
                  : {'id': 4, 'description': 'Dinheiro'},
            ],
            'meta': {'total': 41, 'offset': 20, 'limit': 20},
          }),
          200,
        );
      }),
    );
    expect(
      (await repo.choices(
        customers: true,
        search: ' Maria ',
        offset: 20,
      )).hasNext,
      isTrue,
    );
    expect(
      (await repo.choices(
        customers: false,
        search: 'Maria',
        offset: 20,
      )).rows.single.id,
      4,
    );
    repo.close();
  });
  test(
    'permissão negada impede POST; falha após envio não é reenviada',
    () async {
      await session();
      var posts = 0;
      var allowed = false;
      final repo = BudgetDraftRepository(
        client: MockClient((r) async {
          if (r.url.path.endsWith('/permission/check'))
            return http.Response(jsonEncode({'result': allowed}), 200);
          posts++;
          throw http.ClientException('Conexão perdida');
        }),
      );
      Future<BudgetListEntry> save() => repo.create(
        customer: customer,
        payment: payment,
        date: DateTime(2026),
      );
      await expectLater(save(), throwsStateError);
      expect(posts, 0);
      allowed = true;
      await expectLater(save(), throwsA(isA<BudgetSaveUncertain>()));
      expect(posts, 1);
      repo.close();
    },
  );

  Future<void> fill(WidgetTester t) async {
    await t.ensureVisible(find.text('Selecione um cliente').first);
    await t.tap(find.text('Selecione um cliente').first);
    await t.pumpAndSettle();
    await t.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Cliente',
    );
    await t.tap(find.byTooltip('Buscar cadastro'));
    await t.pumpAndSettle();
    await t.tap(find.text('Cliente do ERP'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Selecione uma forma de pagamento').first);
    await t.tap(find.text('Selecione uma forma de pagamento').first);
    await t.pumpAndSettle();
    await t.tap(find.text('Dinheiro'));
    await t.pumpAndSettle();
  }

  for (final width in [320.0, 1000.0]) {
    testWidgets(
      'Novo valida, confirma uma gravação e atualiza lista em $width',
      (t) async {
        t.view.physicalSize = Size(width, 1000);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        final reader = FakeReader();
        final writer = FakeWriter()..pending = Completer<BudgetListEntry>();
        await t.pumpWidget(
          MaterialApp(
            home: RealBudgetListPage(reader: reader, writer: writer),
          ),
        );
        await t.pumpAndSettle();
        await t.tap(find.text('Novo'));
        await t.pumpAndSettle();
        await t.ensureVisible(find.text('Salvar rascunho'));
        await t.tap(find.text('Salvar rascunho'));
        await t.pumpAndSettle();
        expect(writer.saves, 0);
        await fill(t);
        await t.ensureVisible(find.text('Salvar rascunho'));
        await t.tap(find.text('Salvar rascunho'));
        await t.pumpAndSettle();
        expect(find.text('Criar rascunho no ERP?'), findsOneWidget);
        expect(writer.saves, 0);
        await t.tap(find.text('Criar rascunho'));
        await t.pump();
        expect(writer.saves, 1);
        writer.pending!.complete(BudgetListEntry.fromJson(row(99)));
        await t.pumpAndSettle();
        expect(find.text('Orçamento #99 salvo no ERP.'), findsOneWidget);
        expect(reader.calls, [0, 0]);
        expect(writer.queries, contains('Cliente'));
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets('resultado incerto bloqueia nova gravação', (t) async {
    final writer = FakeWriter()..uncertain = true;
    await t.pumpWidget(MaterialApp(home: NewBudgetPage(writer: writer)));
    await t.pumpAndSettle();
    await fill(t);
    await t.ensureVisible(find.text('Salvar rascunho'));
    await t.tap(find.text('Salvar rascunho'));
    await t.pumpAndSettle();
    await t.tap(find.text('Criar rascunho'));
    await t.pumpAndSettle();
    expect(writer.saves, 1);
    expect(find.text('Voltar à lista'), findsOneWidget);
    final button = t.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Salvar rascunho'),
    );
    expect(button.onPressed, isNull);
    expect(t.takeException(), isNull);
  });
}
