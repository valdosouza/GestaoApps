import '../models/user_model.dart';

/// Data source remota para operações de autenticação
abstract class AuthRemoteDataSource {
  /// Realiza login remoto com email e senha
  /// Lança [Exception] em caso de erro
  Future<UserModel> login({required String email, required String password});

  /// Realiza logout remoto
  Future<void> logout();

  /// Obtém dados do usuário atual do servidor
  Future<UserModel> getCurrentUser();

  /// Registra um novo usuário
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  });

  /// Solicita reset de senha
  Future<void> requestPasswordReset(String email);

  /// Renova o token de autenticação
  Future<String> refreshToken();
}

/// Implementação da data source remota
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // final HttpClient httpClient;

  // AuthRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError('Login não implementado');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<UserModel> getCurrentUser() async {
    throw UnimplementedError('getCurrentUser não implementado');
  }

  @override
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    throw UnimplementedError('Signup não implementado');
  }

  @override
  Future<void> requestPasswordReset(String email) async {}

  @override
  Future<String> refreshToken() async {
    throw UnimplementedError('refreshToken não implementado');
  }
}
