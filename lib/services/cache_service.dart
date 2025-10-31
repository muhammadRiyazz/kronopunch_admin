import 'package:flutter/foundation.dart';
import 'cache_service_mobile.dart'
    if (dart.library.html) 'cache_service_web.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _companyCodeKey = 'company_code';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';
  static const String _userRoleKey = 'user_role';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _loginTimeKey = 'login_time';

  static Future<void> saveLoginData({
    required String companyCode,
    required String email,
    required String name,
    required String role,
  }) async {
    try {
      await CachePlatform.saveData({
        _companyCodeKey: companyCode,
        _userEmailKey: email,
        _userNameKey: name,
        _userRoleKey: role,
        _isLoggedInKey: 'true',
        _loginTimeKey: DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) print('Save login data error: $e');
    }
  }

  static Future<Map<String, String?>> getLoginData() async {
    try {
      final data = await CachePlatform.getData([
        _companyCodeKey,
        _userEmailKey,
        _userNameKey,
        _userRoleKey,
        _isLoggedInKey,
        _loginTimeKey,
      ]);
      return data;
    } catch (e) {
      if (kDebugMode) print('Get login data error: $e');
      return {};
    }
  }

  static Future<bool> isLoggedIn() async {
    final data = await getLoginData();
    return data[_isLoggedInKey] == 'true';
  }

  static Future<void> clearLoginData() async {
    try {
      await CachePlatform.clearData([
        _companyCodeKey,
        _userEmailKey,
        _userNameKey,
        _userRoleKey,
        _isLoggedInKey,
        _loginTimeKey,
      ]);
    } catch (e) {
      if (kDebugMode) print('Clear login data error: $e');
    }
  }

  static Future<String?> getCompanyCode() async {
    final data = await getLoginData();
    return data[_companyCodeKey];
  }

  static Future<String?> getUserRole() async {
    final data = await getLoginData();
    return data[_userRoleKey];
  }
}
