import 'package:core/src/core/error/exceptions.dart';
import 'package:core/src/core/error/failures.dart';
import 'package:core/src/auth/data/datasource/remote/auth_datasource.dart';
import 'package:core/src/auth/domain/entity/auth_entity.dart';
import 'package:core/src/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.datasource});

  final AuthDatasource datasource;

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String username,
    required String password,
  }) async {
    try {
      final result =
          await datasource.login(username: username, password: password);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
