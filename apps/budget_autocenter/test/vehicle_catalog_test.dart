import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_autocenter/src/features/budget/data/repository/complete_budget_repository.dart';
import 'package:budget_autocenter/src/features/budget/presentation/widget/catalog_dialog.dart';
import 'complete_budget_test.dart' show CompleteFake;

class CatalogFake extends CompleteFake {
  bool allowed = true;
  bool fail = false;
  String? savedKind, savedName;
  Map<String, String>? savedParameters;
  @override
  Future<CatalogPage> catalog(
    String kind, {
    String search = '',
    int offset = 0,
    Map<String, String> parameters = const {},
  }) async => CatalogPage([], 0, 0, canCreate: allowed);
  @override
  Future<Map<String, dynamic>> createCatalog(
    String kind,
    String label, {
    Map<String, String> parameters = const {},
  }) async {
    savedKind = kind;
    savedName = label;
    savedParameters = parameters;
    if (fail)
      throw StateError('Usuário sem permissão para incluir neste cadastro.');
    return {'id': 42, 'label': label.toUpperCase()};
  }
}

void main() {
  testWidgets(
    'lista vazia permite cadastrar modelo e retorna seleção com marca',
    (tester) async {
      final api = CatalogFake();
      Map<String, dynamic>? selected;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selected = await chooseCatalog(
                    context,
                    api,
                    'models',
                    'Modelo',
                    parameters: {'brandId': '7'},
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Nenhum cadastro encontrado.'), findsOneWidget);
      await tester.tap(find.text('Cadastrar novo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar e selecionar'));
      await tester.pumpAndSettle();
      expect(find.text('Informe a descrição'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Modelo novo');
      api.fail = true;
      await tester.tap(find.text('Salvar e selecionar'));
      await tester.pumpAndSettle();
      expect(
        find.text('Usuário sem permissão para incluir neste cadastro.'),
        findsOneWidget,
      );
      expect(selected, isNull);
      api.fail = false;
      await tester.tap(find.text('Salvar e selecionar'));
      await tester.pumpAndSettle();
      expect(selected, {'id': 42, 'label': 'MODELO NOVO'});
      expect(api.savedKind, 'models');
      expect(api.savedParameters, {'brandId': '7'});
    },
  );
  testWidgets('permissão negada mantém pesquisa sem botão de inclusão', (
    tester,
  ) async {
    final api = CatalogFake()..allowed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => chooseCatalog(context, api, 'brands', 'Marca'),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Cadastrar novo'), findsNothing);
    expect(find.text('Fechar'), findsOneWidget);
  });
}
