import 'package:dartz/dartz.dart';
import '../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementação do AuthRepository integrando data sources local e remota
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Tenta fazer login remoto
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Salva o usuário localmente
      await localDataSource.saveUser(userModel);

      return Right(userModel);
    } catch (e) {
      return Left(
        Failure(
          message: 'Erro ao fazer login: ${e.toString()}',
          code: 'LOGIN_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clear();
      return const Right(null);
    } catch (e) {
      return Left(
        Failure(
          message: 'Erro ao fazer logout: ${e.toString()}',
          code: 'LOGOUT_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Tenta obter do servidor primeiro
      final userModel = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(userModel);
      return Right(userModel);
    } catch (e) {
      // Se falhar, tenta obter do cache local
      final cachedUser = await localDataSource.getUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      return Left(
        Failure(
          message: 'Erro ao obter usuário: ${e.toString()}',
          code: 'GET_USER_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, User>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.signup(
        name: name,
        email: email,
        password: password,
      );

      await localDataSource.saveUser(userModel);
      return Right(userModel);
    } catch (e) {
      return Left(
        Failure(
          message: 'Erro ao registrar: ${e.toString()}',
          code: 'SIGNUP_ERROR',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> requestPasswordReset(String email) async {
    try {
      await remoteDataSource.requestPasswordReset(email);
      return const Right(null);
    } catch (e) {
      return Left(
        Failure(
          message: 'Erro ao solicitar reset: ${e.toString()}',
          code: 'PASSWORD_RESET_ERROR',
        ),
      );
    }
  }

  @override
  Future<bool> hasValidToken() async {
    try {
      final token = await localDataSource.getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      final newToken = await remoteDataSource.refreshToken();
      await localDataSource.saveToken(newToken);
      return Right(newToken);
    } catch (e) {
      return Left(
        Failure(
          message: 'Erro ao renovar token: ${e.toString()}',
          code: 'REFRESH_TOKEN_ERROR',
        ),
      );
    }
  }
}
