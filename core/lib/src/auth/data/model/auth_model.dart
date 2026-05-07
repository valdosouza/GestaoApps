import 'package:core/src/auth/domain/entity/auth_entity.dart';

/// Model que mapeia o retorno do endpoint `POST auth/login`.
///
/// Retorno esperado:
/// ```json
/// {
///   "authenticated": true,
///   "user": { "id": 5, "name": "Joao Silva", "login": "joao",
///             "level": "V", "active": "S", "salesmanId": 10 }
/// }
/// ```
class AuthModel extends AuthEntity {
  const AuthModel({
    super.authenticated = false,
    super.id = 0,
    super.name = '',
    super.login = '',
    super.level = '',
    super.active = '',
    super.salesmanId = 0,
    super.error = '',
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    final bool authenticated = json['authenticated'] == true;

    if (!authenticated) {
      return AuthModel(
        authenticated: false,
        error: json['message']?.toString() ?? 'Credenciais inválidas.',
      );
    }

    final user = json['user'] as Map<String, dynamic>? ?? {};

    return AuthModel(
      authenticated: true,
      id: _toInt(user['id']),
      name: user['name']?.toString() ?? '',
      login: user['login']?.toString() ?? '',
      level: user['level']?.toString() ?? '',
      active: user['active']?.toString() ?? '',
      salesmanId: _toInt(user['salesmanId']),
    );
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() => {
        'authenticated': authenticated,
        'user': {
          'id': id,
          'name': name,
          'login': login,
          'level': level,
          'active': active,
          'salesmanId': salesmanId,
        },
      };

  static AuthModel empty() => const AuthModel();
}
