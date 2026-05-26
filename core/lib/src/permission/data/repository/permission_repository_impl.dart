import 'package:dartz/dartz.dart';
import 'package:core/src/core/error/failure.dart';
import '../../domain/entity/permission_entity.dart';
import '../../domain/repository/permission_repository.dart';
import '../datasource/remote/permission_remote_datasource.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  PermissionRepositoryImpl({required this.remote});

  final PermissionRemoteDatasource remote;

  @override
  Future<Either<Failure, PermissionEntity>> checkPermission({
    required String menu,
    required String kind,
    required String situation,
  }) async {
    try {
      final result = await remote.checkPermission(
        menu: menu,
        kind: kind,
        situation: situation,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
