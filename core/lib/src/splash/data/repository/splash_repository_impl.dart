import 'package:core/src/error/exceptions.dart';
import 'package:core/src/error/failures.dart';
import 'package:core/src/splash/data/datasource/splash_datasource.dart';
import 'package:core/src/splash/domain/repository/splash_respository.dart';
import 'package:dartz/dartz.dart';

class SplashRepositoryImpl implements SplashRepository {
  final SplashDataSource datasource;

  SplashRepositoryImpl({required this.datasource});

  @override
  Future<Either<Failure, bool>> getAuthorization() async {
    try {
      final auth = await datasource.getAuthorization();
      return Right(auth);
    } on ServerException {
      return Left(ServerFailure());
    }
  }
}
