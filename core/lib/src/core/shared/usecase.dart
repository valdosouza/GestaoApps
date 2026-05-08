import 'package:core/src/core/error/failure.dart';
import 'package:dartz/dartz.dart';

abstract class UseCase<Output, Params> {
  Future<Either<Failure, Output>> call(Params params);
}
