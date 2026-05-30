import 'dart:convert';
import 'package:core/gateway.dart';
import '../../model/permission_model.dart';

class PermissionRemoteDatasource extends Gateway {
  PermissionRemoteDatasource({required super.httpClient});

  Future<PermissionModel> checkPermission({
    required String menu,
    required String kind,
    required String situation,
  }) async {
    final userId = await getUserId();
    final userLevel = await getUserLevel();
    return request(
      'permission/check',
      (raw) => PermissionModel.fromRawJson(raw as String),
      method: HTTPMethod.post,
      data: jsonEncode({
        'userId': userId,
        'userLevel': userLevel,
        'menu': menu,
        'kind': kind,
        'situation': situation,
      }),
    );
  }
}
