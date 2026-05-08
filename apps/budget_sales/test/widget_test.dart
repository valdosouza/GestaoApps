import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_sales/app.dart';
import 'package:budget_sales/src/features/budget/budget_module.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ModularApp(module: BudgetModule(), child: const MyApp()),
    );
    await tester.pump();
  });
}
