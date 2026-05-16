import 'dart:convert';
import 'package:core/src/gateway.dart';

abstract class SplashDataSource extends Gateway {
  SplashDataSource({required super.httpClient});

  Future<bool> getAuthorization();
}

class SplashDataSourceImpl extends SplashDataSource {
  SplashDataSourceImpl({required super.httpClient});
  @override
  Future<bool> getAuthorization() => request(
        'auth/authorization',
        (payload) {
          final data = json.decode(payload);
          return (data['message'] == 'Valid Token');
        },
        onError: (error) => false,
      );
}
