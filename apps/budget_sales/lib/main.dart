import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'app.dart';
import 'src/features/budget/budget_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ModularApp(module: BudgetModule(), child: const MyApp()));
}
