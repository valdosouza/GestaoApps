import 'package:core/src/core/error/exceptions.dart';
import 'package:core/src/core/error/failures.dart';
import 'package:core/src/core/shared/usecase.dart';
import 'package:core/src/auth/domain/entity/auth_entity.dart';
import 'package:core/src/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class LoginEmail implements UseCase<AuthEntity, LoginParams> {
  final AuthRepository repository;

  LoginEmail({required this.repository});

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) async {
    try {
      return await repository.login(
        username: params.username,
        password: params.password,
      );
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}

class LoginParams extends Equatable {
  final String username;
  final String password;

  const LoginParams({
    required this.username,
    required this.password,
  });

  @override
  List<Object?> get props => [username, password];
}
