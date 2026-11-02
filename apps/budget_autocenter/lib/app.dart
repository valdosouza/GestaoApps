import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'src/core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'AutoCenter Orçamento',
    debugShowCheckedModeBanner: false,
    theme: appTheme(),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
    routerDelegate: Modular.routerDelegate,
    routeInformationParser: Modular.routeInformationParser,
  );
}
