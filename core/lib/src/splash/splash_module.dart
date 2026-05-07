import 'package:core/src/splash/presentation/bloc/splash_bloc.dart';
import 'package:core/src/splash/presentation/page/splash_page.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_bloc_bind/modular_bloc_bind.dart';

class SplashModule extends Module {
  @override
  List<Bind> get binds => [
        BlocBind.singleton((i) => SplashBloc()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/', child: (_, args) => const SplashPage()),
      ];
}
