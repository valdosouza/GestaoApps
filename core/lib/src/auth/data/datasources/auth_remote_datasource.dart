import '../models/user_model.dart';

/// Data source remota para operações de autenticação
abstract class AuthRemoteDataSource {
  /// Realiza login remoto com email e senha
  /// Lança [Exception] em caso de erro
  Future<UserModel> login({
    required String email,
    required String password,
  });

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
  // TODO: Injetar cliente HTTP (Dio, Http, etc)
  // final HttpClient httpClient;

  // AuthRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // TODO: Implementar chamada HTTP
    throw UnimplementedError('Login não implementado');
  }

  @override
  Future<void> logout() async {
    // TODO: Implementar logout remoto
  }

  @override
  Future<UserModel> getCurrentUser() async {
    // TODO: Implementar busca do usuário atual
    throw UnimplementedError('getCurrentUser não implementado');
  }

  @override
  Future<UserModel> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    // TODO: Implementar registro remoto
    throw UnimplementedError('Signup não implementado');
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    // TODO: Implementar requisição de reset
  }

  @override
  Future<String> refreshToken() async {
    // TODO: Implementar renovação de token
    throw UnimplementedError('refreshToken não implementado');
  }
}
