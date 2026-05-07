import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Data source local para operações de autenticação
abstract class AuthLocalDataSource {
  /// Salva o usuário localmente
  Future<void> saveUser(UserModel user);

  /// Obtém o usuário salvo localmente
  Future<UserModel?> getUser();

  /// Salva o token de autenticação
  Future<void> saveToken(String token);

  /// Obtém o token salvo
  Future<String?> getToken();

  /// Remove o usuário e token (logout)
  Future<void> clear();

  /// Verifica se existe um usuário salvo
  Future<bool> hasUser();
}

/// Implementação da data source local usando SharedPreferences
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';

  final SharedPreferences _preferences;

  AuthLocalDataSourceImpl({required SharedPreferences preferences})
      : _preferences = preferences;

  @override
  Future<void> saveUser(UserModel user) async {
    final json = jsonEncode(user.toJson());
    await _preferences.setString(_userKey, json);
  }

  @override
  Future<UserModel?> getUser() async {
    final json = _preferences.getString(_userKey);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    await _preferences.setString(_tokenKey, token);
  }

  @override
  Future<String?> getToken() async {
    return _preferences.getString(_tokenKey);
  }

  @override
  Future<void> clear() async {
    await _preferences.remove(_userKey);
    await _preferences.remove(_tokenKey);
  }

  @override
  Future<bool> hasUser() async {
    return _preferences.containsKey(_userKey);
  }
}
