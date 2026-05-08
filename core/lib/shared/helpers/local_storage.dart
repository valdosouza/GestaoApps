import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<dynamic> get({required String key, dynamic defaultValue});
  Future<void> delete({required String key});
  bool hasKey({required String key});
  Future<void> saveItem({required String key, required dynamic value});
}

class LocalStorageService implements LocalStorage {
  LocalStorageService._() {
    unawaited(initializeIfNeeded());
  }

  static LocalStorage? _instance;

  static LocalStorage get instance => _instance ??= LocalStorageService._();

  SharedPreferences? _storage;

  Future<void> initializeIfNeeded() async {
    if (_storage == null) {
      debugPrint('Initializing storage');
      _storage = await SharedPreferences.getInstance();
    }
  }

  @override
  Future delete({required String key}) async {
    await initializeIfNeeded();
    _storage?.remove(key);
  }

  @override
  Future get({required String key, dynamic defaultValue}) async {
    await initializeIfNeeded();
    return _storage?.get(key) ?? defaultValue;
  }

  @override
  Future saveItem({required String key, required dynamic value}) async {
    await initializeIfNeeded();
    if (value is bool) {
      await _storage?.setBool(key, value);
    } else if (value is String) {
      await _storage?.setString(key, value);
    } else if (value is int) {
      await _storage?.setInt(key, value);
    } else if (value is double) {
      await _storage?.setDouble(key, value);
    } else {
      await _storage?.setString(key, value.toString());
    }
  }

  @override
  bool hasKey({required String key}) => _storage?.containsKey(key) ?? false;
}
