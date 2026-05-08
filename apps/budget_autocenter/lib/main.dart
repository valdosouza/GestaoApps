import 'package:flutter/material.dart';
import 'app.dart';
import 'src/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final deps = await AppDependencies.create();
    runApp(MyApp(deps: deps));
  } catch (e, stackTrace) {
    // TODO: Implementar error handling
    print('Erro ao inicializar app: $e');
    print('Stack trace: $stackTrace');
  }
}
