import 'dart:convert';
import '../../domain/entity/permission_entity.dart';

class PermissionModel extends PermissionEntity {
  const PermissionModel({required super.result});

  factory PermissionModel.fromJson(Map<String, dynamic> json) =>
      PermissionModel(result: json['result'] as bool? ?? false);

  factory PermissionModel.fromRawJson(String rawJson) =>
      PermissionModel.fromJson(jsonDecode(rawJson) as Map<String, dynamic>);
}
