import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:core/shared/helpers/local_storage.dart';
import 'package:budget_autocenter/src/features/budget/data/repository/real_budget_list_repository.dart';
import 'package:budget_autocenter/src/features/budget/domain/entity/budget_list_entry.dart';
import 'package:budget_autocenter/src/features/budget/presentation/page/real_budget_list_page.dart';

Map<String, dynamic> row(int id, {int institution = 7}) => {
  'id': id,
  'institutionId': institution,
  'number': 'ORC-$id',
  'customerName': 'Cliente real de teste',
  'date': '2026-11-02T00:00:00.000Z',
  'total': 1234.56,
  'status': 'N',
};
Map<String, dynamic> envelope() => {
  'data': [row(8)],
  'meta': {'total': 21, 'limit': 20, 'offset': 0},
};

class FakeReader implements BudgetListReader {
  final calls = <int>[];
  final criteria = <List<String?>>[];
  bool fail = false;
  @override
  Future<BudgetListPageData> load({
    int offset = 0,
    int limit = 20,
    DateTime? from,
    DateTime? to,
    String? number,
    String? customerName,
  }) async {
    calls.add(offset);
    criteria.add([number, customerName]);
    if (fail) throw StateError('Servidor indisponível');
    return BudgetListPageData(
      [BudgetListEntry.fromJson(row(offset + 1))],
      21,
      offset,
      20,
    );
  }

  @override
  void close() {}
}

void main() {
  setUpAll(() => SharedPreferences.setMockInitialValues({}));
  Future<void> session({String token = 'teste'}) async {
    final storage = LocalStorageService.instance;
    await storage.saveItem(key: 'server_ip', value: '127.0.0.1');
    await storage.saveItem(key: 'tb_institution_id', value: '7');
    await storage.saveItem(key: 'token', value: token);
    await storage.saveItem(key: 'tb_user_id', value: 3);
    await storage.saveItem(key: 'user_level', value: '1');
  }

  test(
    'consulta usa sessão, estabelecimento, datas e paginação corretos',
    () async {
      await session();
      final requests = <http.Request>[];
      final repo = RealBudgetListRepository(
        client: MockClient((request) async {
          requests.add(request);
          expect(request.headers['Authorization'], 'Bearer teste');
          if (request.url.path.endsWith('permission/check')) {
            expect(jsonDecode(request.body)['menu'], 'Fr_Cotacao');
            return http.Response('{"result":true}', 200);
          }
          expect(request.method, 'GET');
          expect(request.url.queryParameters, {
            'institutionId': '7',
            'limit': '20',
            'offset': '0',
            'number': 'ORC-8',
            'customerName': 'Cliente',
            'dateFrom': '2026-11-01',
            'dateTo': '2026-11-02',
          });
          return http.Response(jsonEncode(envelope()), 200);
        }),
      );
      final data = await repo.load(
        number: ' ORC-8 ',
        customerName: ' Cliente ',
        from: DateTime(2026, 11, 1),
        to: DateTime(2026, 11, 2),
      );
      expect(data.total, 21);
      expect(data.hasNext, isTrue);
      expect(data.rows.single.totalCents, 123456);
      expect(data.rows.single.date, DateTime(2026, 11, 2));
      expect(requests.length, 2);
      repo.close();
    },
  );
  test('não consulta sem sessão ou sem estabelecimento', () async {
    await session(token: '');
    final repo = RealBudgetListRepository(
      client: MockClient((_) async => throw StateError('Não deve consultar')),
    );
    await expectLater(repo.load(), throwsStateError);
    await session();
    await LocalStorageService.instance.saveItem(
      key: 'tb_institution_id',
      value: '',
    );
    await expectLater(repo.load(), throwsStateError);
    repo.close();
  });
  test('nega permissão antes de consultar orçamentos', () async {
    await session();
    var calls = 0;
    final repo = RealBudgetListRepository(
      client: MockClient((r) async {
        calls++;
        expect(r.url.path.endsWith('permission/check'), isTrue);
        return http.Response('{"result":false}', 200);
      }),
    );
    await expectLater(repo.load(), throwsStateError);
    expect(calls, 1);
    repo.close();
  });
  test('rejeita dados de outro estabelecimento e falhas de API', () async {
    await session();
    final repo = RealBudgetListRepository(
      client: MockClient((r) async {
        if (r.url.path.endsWith('permission/check'))
          return http.Response('{"result":true}', 200);
        return http.Response(
          jsonEncode({
            'data': [row(8, institution: 9)],
            'meta': {'total': 1, 'limit': 20, 'offset': 0},
          }),
          200,
        );
      }),
    );
    await expectLater(repo.load(), throwsFormatException);
    repo.close();
  });
  for (final width in [320.0, 1000.0]) {
    testWidgets('lista real pagina, mostra filtros e Novo em $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final reader = FakeReader();
      await tester.pumpWidget(
        MaterialApp(
          home: RealBudgetListPage(
            reader: reader,
            detailBuilder: (id) => Scaffold(body: Text('Detalhes $id')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ORC-1'), findsOneWidget);
      expect(find.text('R\$ 1.234,56'), findsOneWidget);
      expect(find.text('Novo'), findsOneWidget);
      expect(find.text('Número'), findsOneWidget);
      expect(find.text('Cliente'), findsOneWidget);
      await tester.tap(find.text('Próxima'));
      await tester.pumpAndSettle();
      expect(reader.calls, [0, 20]);
      expect(find.text('ORC-21'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('real-budget-21')));
      await tester.pumpAndSettle();
      expect(find.text('Detalhes 21'), findsOneWidget);
      expect(find.byType(TextFormField), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'Buscar aplica filtros globais, pagina preserva e Limpar remove',
    (tester) async {
      final reader = FakeReader();
      await tester.pumpWidget(
        MaterialApp(home: RealBudgetListPage(reader: reader)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Número'), '10231');
      await tester.enterText(
        find.widgetWithText(TextField, 'Cliente'),
        'CARON',
      );
      expect(reader.calls, [0]);
      await tester.tap(find.text('Buscar'));
      await tester.pumpAndSettle();
      expect(reader.criteria.last, ['10231', 'CARON']);
      expect(reader.calls, [0, 0]);
      await tester.enterText(
        find.widgetWithText(TextField, 'Cliente'),
        'NÃO APLICADO',
      );
      await tester.tap(find.text('Próxima'));
      await tester.pumpAndSettle();
      expect(reader.calls.last, 20);
      expect(reader.criteria.last, ['10231', 'CARON']);
      await tester.tap(find.text('Limpar'));
      await tester.pumpAndSettle();
      expect(reader.calls.last, 0);
      expect(reader.criteria.last, ['', '']);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('erro oferece tentativa sem mostrar exemplos fictícios', (
    tester,
  ) async {
    final reader = FakeReader()..fail = true;
    await tester.pumpWidget(
      MaterialApp(home: RealBudgetListPage(reader: reader)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Servidor indisponível'), findsOneWidget);
    expect(find.text('DEMO-001'), findsNothing);
    reader.fail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('ORC-1'), findsOneWidget);
  });
}
