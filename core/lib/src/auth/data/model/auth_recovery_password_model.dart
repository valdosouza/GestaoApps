import 'package:core/src/auth/domain/entity/auth_recovery_password_entity.dart';

class AuthRecoveryPasswordModel extends AuthRecoveryPasswordEntity {
  AuthRecoveryPasswordModel({
    required super.tbUserId,
    required super.email,
  });

  AuthRecoveryPasswordModel.empty()
      : this(tbUserId: 0, email: '');

  factory AuthRecoveryPasswordModel.fromJson(Map<String, dynamic> json) =>
      AuthRecoveryPasswordModel(
        tbUserId: json['tb_user_id'],
        email: json['email'] as String? ?? '',
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['tb_user_id'] = tbUserId;
    data['email'] = email;
    return data;
  }
}
