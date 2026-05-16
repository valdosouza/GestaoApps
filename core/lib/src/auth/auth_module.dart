import 'package:core/src/auth/data/datasource/remote/auth_datasource.dart';
import 'package:core/src/auth/data/repository/auth_repository_impl.dart';
import 'package:core/src/auth/domain/usecase/login_email.dart';
import 'package:core/src/auth/presentation/bloc/auth_bloc.dart';
import 'package:core/src/auth/presentation/page/auth_page.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:modular_bloc_bind/modular_bloc_bind.dart';
import 'package:http/http.dart' as http;

class AuthModule extends Module {
  AuthModule({this.onSuccessRoute = '/budget/'});

  /// Rota para navegar após login bem-sucedido.
  /// Padrão: '/budget/' para manter compatibilidade com o app de orçamento.
  final String onSuccessRoute;

  @override
  List<Bind> get binds => [
        Bind.singleton<AuthDatasourceImpl>(
          (i) => AuthDatasourceImpl(httpClient: http.Client()),
        ),
        Bind.singleton(
          (i) => AuthRepositoryImpl(datasource: i.get<AuthDatasourceImpl>()),
        ),
        Bind.factory(
          (i) => LoginEmail(repository: i.get<AuthRepositoryImpl>()),
        ),
        BlocBind.singleton(
          (i) => AuthBloc(loginEmail: i.get<LoginEmail>()),
        ),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute(
          '/',
          child: (_, args) => AuthPage(onSuccessRoute: onSuccessRoute),
        ),
      ];
}
