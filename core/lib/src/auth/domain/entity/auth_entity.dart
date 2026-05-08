/// Representa o usuário autenticado retornado pelo endpoint `auth/login`.
///
/// Retorno da API:
/// ```json
/// {
///   "authenticated": true,
///   "user": { "id": 5, "name": "Joao Silva", "login": "joao",
///             "level": "V", "active": "S", "salesmanId": 10 }
/// }
/// ```
class AuthEntity {
  const AuthEntity({
    required this.authenticated,
    required this.id,
    required this.name,
    required this.login,
    required this.level,
    required this.active,
    required this.salesmanId,
    required this.error,
  });

  const AuthEntity.empty()
      : authenticated = false,
        id = 0,
        name = '',
        login = '',
        level = '',
        active = '',
        salesmanId = 0,
        error = '';

  final bool authenticated;
  final int id;
  final String name;
  final String login;
  final String level;
  final String active;
  final int salesmanId;
  final String error;
}
