import 'package:flutter/material.dart';
import 'package:core/core.dart';
import 'app.dart';
import 'src/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Setup dependências do core
    await setupCoreInjection();

    // Setup dependências do app
    setupAppInjection();

    runApp(const MyApp());
  } catch (e, stackTrace) {
    // TODO: Implementar error handling
    print('Erro ao inicializar app: $e');
    print('Stack trace: $stackTrace');
  }
}
