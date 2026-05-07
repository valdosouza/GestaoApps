import 'package:core/src/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class SplashRepository {
  Future<Either<Failure, bool>> getAuthorization();
}
