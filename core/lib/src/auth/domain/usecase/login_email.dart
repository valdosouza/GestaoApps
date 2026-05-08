import 'package:core/src/core/error/exceptions.dart';
import 'package:core/src/core/error/failures.dart';
import 'package:core/src/core/shared/usecase.dart';
import 'package:core/src/auth/domain/entity/auth_entity.dart';
import 'package:core/src/auth/domain/repository/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class LoginEmail implements UseCase<AuthEntity, LoginParams> {
  LoginEmail({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) async {
    try {
      return await repository.login(
        username: params.username,
        password: params.password,
      );
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}

class LoginParams extends Equatable {
  const LoginParams({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}
