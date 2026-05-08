import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/data/datasources/auth_local_datasource.dart';
import '../../auth/data/datasources/auth_remote_datasource.dart';
import '../../auth/data/repositories/auth_repository_impl.dart';
import '../../auth/domain/usecases/login.dart';

class CoreDependencies {
  CoreDependencies._({
    required this.prefs,
    required this.authLocalDataSource,
    required this.authRemoteDataSource,
    required this.authRepository,
    required this.loginUseCase,
  });

  final SharedPreferences prefs;
  final AuthLocalDataSource authLocalDataSource;
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthRepositoryImpl authRepository;
  final LoginUseCase loginUseCase;

  static Future<CoreDependencies> create() async {
    final prefs = await SharedPreferences.getInstance();
    final authLocalDataSource = AuthLocalDataSourceImpl(preferences: prefs);
    final authRemoteDataSource = AuthRemoteDataSourceImpl();
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );
    final loginUseCase = LoginUseCase(authRepository);

    return CoreDependencies._(
      prefs: prefs,
      authLocalDataSource: authLocalDataSource,
      authRemoteDataSource: authRemoteDataSource,
      authRepository: authRepository,
      loginUseCase: loginUseCase,
    );
  }
}
