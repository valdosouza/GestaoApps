import 'package:dartz/dartz.dart';
import 'package:core/src/core/error/failure.dart';
import '../entity/permission_entity.dart';

abstract class PermissionRepository {
  Future<Either<Failure, PermissionEntity>> checkPermission({
    required String menu,
    required String kind,
    required String situation,
  });
}
