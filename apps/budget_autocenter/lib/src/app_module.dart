import 'package:core/core.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'features/budget/budget_module.dart';

/// Mesmo fluxo do Sales: splash → servidor/login → orçamentos.
class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
    ModuleRoute('/', module: SplashModule()),
    ModuleRoute('/auth/', module: AuthModule()),
    ChildRoute('/server-config/', child: (_, __) => const ServerIpPage()),
    ModuleRoute('/budget/', module: BudgetModule()),
  ];
}
