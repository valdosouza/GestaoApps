import 'package:core/core.dart';
import 'package:budget_sales/src/features/budget/budget_module.dart';
import 'package:flutter_modular/flutter_modular.dart';

/// Módulo raiz do app Budget Sales.
///
/// Fluxo de navegação:
///   App inicia → / (SplashPage)
///     ├─ IP não configurado  → /server-config/
///     ├─ Não autenticado     → /auth/
///     └─ Autenticado         → /budget/
///
/// Após login bem-sucedido (AuthPage) → /budget/
/// Após salvar servidor (ServerIpPage) → /auth/
class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        // Splash — tela inicial que verifica IP e sessão
        ModuleRoute('/', module: SplashModule()),

        // Auth — login via core
        ModuleRoute('/auth/', module: AuthModule()),

        // Configuração do servidor — página do core, sem módulo dedicado
        ChildRoute(
          '/server-config/',
          child: (_, __) => const ServerIpPage(),
        ),

        // Feature principal do app
        ModuleRoute('/budget/', module: BudgetModule()),
      ];
}
