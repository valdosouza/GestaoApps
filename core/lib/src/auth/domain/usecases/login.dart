import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case para realizar login
class LoginUseCase {
  LoginUseCase(this.repository);

  final AuthRepository repository;

  /// Executa o login com email e senha
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // Validação básica
    if (email.isEmpty || password.isEmpty) {
      return const Left(
        Failure(
          message: 'Email e senha são obrigatórios',
          code: 'INVALID_INPUT',
        ),
      );
    }

    return repository.login(email: email, password: password);
  }
}
