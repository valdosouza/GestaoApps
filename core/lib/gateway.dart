import 'dart:io';

import 'package:core/shared/constants.dart';
import 'package:core/shared/helpers/local_storage.dart';
import 'package:core/shared/local_storage_key.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class Gateway {
  Gateway({required this.httpClient});

  final http.Client httpClient;
  int statusCode = 0;

  Future<String> getBaseUrl() async {
    final ip = await LocalStorageService.instance
        .get(key: LocalStorageKey.serverIp, defaultValue: '');
    if (ip == null || ip.toString().isEmpty) {
      throw Exception('IP do servidor não configurado.');
    }
    return buildBaseApiUrl(ip.toString());
  }

  Future<String> getToken() async {
    final value = await LocalStorageService.instance
        .get(key: LocalStorageKey.token, defaultValue: '');
    return value?.toString() ?? '';
  }

  Future<dynamic> getInstitutionId() async =>
      LocalStorageService.instance.get(key: LocalStorageKey.tbInstitutionId, defaultValue: 0);

  Future<dynamic> getUserId() async =>
      LocalStorageService.instance.get(key: LocalStorageKey.tbUserId, defaultValue: 0);

  Future<int> getSalesmanId() async {
    final value = await LocalStorageService.instance
        .get(key: LocalStorageKey.salesmanId, defaultValue: 0);
    if (value == null) {
      return 0;
    }
    return value is int ? value : int.tryParse(value.toString()) ?? 0;
  }

  Future<Map<String, String>> requestOptions() async => {
        HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        'Access-Control-Allow-Origin': '*',
        'Accept': '*/*',
      };

  Future<T> request<T>(
    String url,
    T Function(dynamic) fromJson, {
    dynamic data = const {},
    HTTPMethod method = HTTPMethod.get,
    Duration timeout = const Duration(milliseconds: 10000),
    Function(Exception)? onError,
  }) async {
    debugPrint('${method.name.toUpperCase()} $url');
    debugPrint(data.toString());

    try {
      final baseUrl = await getBaseUrl();
      late Response response;

      switch (method) {
        case HTTPMethod.get:
          response = await _get(baseUrl, url, timeout);
          break;
        case HTTPMethod.post:
          response = await _post(baseUrl, url, data, timeout);
          break;
        case HTTPMethod.put:
          response = await _put(baseUrl, url, data, timeout);
          break;
        case HTTPMethod.delete:
          response = await _delete(baseUrl, url, timeout);
          break;
      }

      statusCode = response.statusCode;
      if (statusCode < 200 || statusCode >= 300) {
        throw HttpException(
          'Request failed [$statusCode] for "$url": ${response.body}',
        );
      }
      return fromJson(response.body);
    } on Exception catch (e) {
      debugPrint('Gateway error [$statusCode] $url → $e');
      if (onError != null) {
        return onError(e);
      }
      rethrow;
    }
  }

  Future<Response> _get(String baseUrl, String url, Duration timeout) async =>
      httpClient
          .get(Uri.parse('$baseUrl$url'), headers: await requestOptions())
          .timeout(timeout);

  Future<Response> _post(
          String baseUrl, String url, dynamic data, Duration timeout) async =>
      httpClient
          .post(Uri.parse('$baseUrl$url'),
              headers: await requestOptions(), body: data)
          .timeout(timeout);

  Future<Response> _put(
          String baseUrl, String url, dynamic data, Duration timeout) async =>
      httpClient
          .put(Uri.parse('$baseUrl$url'),
              headers: await requestOptions(), body: data)
          .timeout(timeout);

  Future<Response> _delete(
          String baseUrl, String url, Duration timeout) async =>
      httpClient
          .delete(Uri.parse('$baseUrl$url'), headers: await requestOptions())
          .timeout(timeout);
}

enum HTTPMethod { get, post, delete, put }
