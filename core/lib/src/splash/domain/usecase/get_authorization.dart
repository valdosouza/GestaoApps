import 'package:core/src/error/exceptions.dart';
import 'package:core/src/error/failures.dart';
import 'package:core/src/shared/usecase.dart';
import 'package:core/src/splash/domain/repository/splash_respository.dart';
import 'package:dartz/dartz.dart';

class GetAuthorization implements UseCase<bool, ParamsAuthorization> {
  GetAuthorization({required this.repository});

  final SplashRepository repository;

  @override
  Future<Either<Failure, bool>> call(ParamsAuthorization params) async {
    try {
      return await repository.getAuthorization();
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}

class ParamsAuthorization {
  ParamsAuthorization();
}
