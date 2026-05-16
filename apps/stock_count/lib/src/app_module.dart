import 'package:core/core.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'features/stock_count/stock_count_module.dart';

/// Módulo raiz do app Stock Count.
///
/// Fluxo de navegação:
///   App inicia → / (SplashPage)
///     ├─ IP não configurado  → /server-config/
///     ├─ Não autenticado     → /auth/
///     └─ Autenticado         → /stock-count/
///
/// Após login bem-sucedido (AuthPage)      → /stock-count/
/// Após salvar servidor (ServerIpPage)     → /auth/
class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        // Splash — verifica IP e sessão
        ModuleRoute('/', module: SplashModule()),

        // Auth — login via core; redireciona para /stock-count/ após sucesso
        ModuleRoute('/auth/', module: AuthModule(onSuccessRoute: '/stock-count/')),

        // Configuração do servidor — página do core
        ChildRoute(
          '/server-config/',
          child: (_, __) => const ServerIpPage(),
        ),

        // Feature principal do app
        ModuleRoute('/stock-count/', module: StockCountModule()),
      ];
}
