import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../entities/user.dart';

/// Repository abstrato para operações de autenticação
abstract class AuthRepository {
  /// Realiza login com email e senha
  /// Retorna [Right<User>] em caso de sucesso ou [Left<Failure>] em caso de erro
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Realiza logout do usuário
  Future<Either<Failure, void>> logout();

  /// Obtém o usuário atualmente autenticado
  Future<Either<Failure, User>> getCurrentUser();

  /// Cria uma nova conta de usuário
  Future<Either<Failure, User>> signup({
    required String name,
    required String email,
    required String password,
  });

  /// Solicita reset de senha
  Future<Either<Failure, void>> requestPasswordReset(String email);

  /// Valida se existe um token salvo
  Future<bool> hasValidToken();

  /// Renova o token de autenticação
  Future<Either<Failure, String>> refreshToken();
}
