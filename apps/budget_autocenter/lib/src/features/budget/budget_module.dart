import 'package:flutter_modular/flutter_modular.dart';
import 'presentation/page/autocenter_budget_page.dart';

/// Fluxo aprovado. Dados de orçamento ainda demonstrativos; auth vem do core.
class BudgetModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ChildRoute('/', child: (_, __) => const AutoCenterBudgetPage()),
  ];
}
