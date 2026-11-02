import 'package:budget_autocenter/app.dart';
import 'package:budget_autocenter/src/app_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('entrada principal abre configuração inicial sem servidor salvo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(ModularApp(module: AppModule(), child: const MyApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(Modular.to.path, startsWith('/server-config/'));
    expect(find.text('Configuração Inicial'), findsOneWidget);
    expect(find.text('Explorar o aplicativo'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    Modular.destroy();
  });
}
