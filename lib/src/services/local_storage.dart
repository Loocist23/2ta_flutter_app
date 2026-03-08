import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Small wrapper around [SharedPreferences] so we can mock or extend it easily.
class LocalStorage {
  LocalStorage(this._preferences);

  final SharedPreferences _preferences;

  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  Future<String?> getItem(String key) async {
    return _preferences.getString(key);
  }

  Future<void> setItem(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<void> removeItem(String key) async {
    await _preferences.remove(key);
  }

  Future<void> setJson(String key, Map<String, dynamic> value) {
    return setItem(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getJson(String key) async {
    final content = await getItem(key);
    if (content == null) {
      return null;
    }
    return jsonDecode(content) as Map<String, dynamic>;
  }

  // Token management
  static const _authTokenKey = '2ta.auth.token';
  static const _refreshTokenKey = '2ta.auth.refreshToken';

  Future<void> saveAuthToken(String token) async {
    await setItem(_authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return await getItem(_authTokenKey);
  }

  Future<void> clearAuthToken() async {
    await removeItem(_authTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await setItem(_refreshTokenKey, token);
  }

  Future<String?> getRefreshToken() async {
    return await getItem(_refreshTokenKey);
  }

  Future<void> clearRefreshToken() async {
    await removeItem(_refreshTokenKey);
  }

  Future<void> clearAllAuthTokens() async {
    await clearAuthToken();
    await clearRefreshToken();
  }
}
