import 'package:dartz/dartz.dart';
import 'package:core/src/core/error/failure.dart';
import '../entity/permission_entity.dart';
import '../repository/permission_repository.dart';

class CheckPermission {
  CheckPermission(this._repository);

  final PermissionRepository _repository;

  Future<Either<Failure, PermissionEntity>> call({
    required String menu,
    required String kind,
    required String situation,
  }) =>
      _repository.checkPermission(menu: menu, kind: kind, situation: situation);
}
