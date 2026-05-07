import 'package:core/src/core/error/failures.dart';
import 'package:core/src/auth/domain/entity/auth_entity.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String username,
    required String password,
  });
}
