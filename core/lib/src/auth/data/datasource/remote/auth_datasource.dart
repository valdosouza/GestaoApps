import 'dart:convert';

import 'package:core/src/core/error/exceptions.dart';
import 'package:core/src/core/gateway.dart';
import 'package:core/src/auth/data/model/auth_model.dart';
import 'package:crypto/crypto.dart';

/// Contrato do datasource de autenticação.
abstract class AuthDatasource extends Gateway {
  AuthDatasource({required super.httpClient});

  Future<AuthModel> login({
    required String username,
    required String password,
  });
}

/// Implementação que consome `POST auth/login` da API local.
///
/// A senha é encriptada com MD5 antes do envio, pois o banco
/// armazena o hash e a comparação é direta no servidor.
class AuthDatasourceImpl extends AuthDatasource {
  AuthDatasourceImpl({required super.httpClient});

  @override
  Future<AuthModel> login({
    required String username,
    required String password,
  }) async {
    final passwordMd5 =
        md5.convert(utf8.encode(password)).toString().toUpperCase();

    return request(
      'auth/login',
      method: HTTPMethod.post,
      data: jsonEncode(<String, String>{
        'login': username,
        'senha': passwordMd5,
      }),
      (payload) {
        final jsonMap = json.decode(payload) as Map<String, dynamic>;
        return AuthModel.fromJson(jsonMap);
      },
      onError: (error) {
        throw ServerException();
      },
    );
  }
}
