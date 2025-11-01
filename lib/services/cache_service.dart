// services/cache_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static SharedPreferences? _prefs;
  static bool _initialized = false;

  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
      debugPrint('✅ CacheService initialized successfully');
    } catch (e) {
      debugPrint('❌ CacheService initialization failed: $e');
      _initialized = false;
    }
  }

  static Future<void> saveLoginData({
    required String companyCode,
    required String email,
    required String name,
    required String role,
  }) async {
    await _ensureInitialized();
    
    if (!_initialized || _prefs == null) {
      debugPrint('❌ Cache not available - skipping save');
      return;
    }

    try {
      await _prefs!.setString(_companyCodeKey, companyCode);
      await _prefs!.setString(_userEmailKey, email);
      await _prefs!.setString(_userNameKey, name);
      await _prefs!.setString(_userRoleKey, role);
      await _prefs!.setBool(_isLoggedInKey, true);
      await _prefs!.setString(_loginTimeKey, DateTime.now().toIso8601String());
      
      debugPrint('✅ Login data saved successfully:');
      debugPrint('   - Name: $name');
      debugPrint('   - Email: $email');
      debugPrint('   - Company: $companyCode');
      debugPrint('   - Role: $role');
    } catch (e) {
      debugPrint('❌ Error saving to cache: $e');
    }
  }

  static Future<Map<String, String?>> getLoginData() async {
    await _ensureInitialized();
    
    if (!_initialized || _prefs == null) {
      debugPrint('❌ Cache not available - returning empty data');
      return {};
    }

    try {
      final data = {
        'companyCode': _prefs!.getString(_companyCodeKey),
        'email': _prefs!.getString(_userEmailKey),
        'name': _prefs!.getString(_userNameKey),
        'role': _prefs!.getString(_userRoleKey),
        'isLoggedIn': _prefs!.getBool(_isLoggedInKey)?.toString(),
        'loginTime': _prefs!.getString(_loginTimeKey),
      };
      
      debugPrint('📥 Retrieved cache data:');
      debugPrint('   - Name: ${data['name']}');
      debugPrint('   - Email: ${data['email']}');
      debugPrint('   - Company: ${data['companyCode']}');
      debugPrint('   - Role: ${data['role']}');
      debugPrint('   - IsLoggedIn: ${data['isLoggedIn']}');
      
      return data;
    } catch (e) {
      debugPrint('❌ Error reading from cache: $e');
      return {};
    }
  }

  static Future<bool> isLoggedIn() async {
    await _ensureInitialized();
    
    if (!_initialized || _prefs == null) {
      return false;
    }

    try {
      return _prefs!.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      debugPrint('❌ Error checking login status: $e');
      return false;
    }
  }

  static Future<void> clearLoginData() async {
    await _ensureInitialized();
    
    if (!_initialized || _prefs == null) {
      debugPrint('❌ Cache not available - skipping clear');
      return;
    }

    try {
      await _prefs!.remove(_companyCodeKey);
      await _prefs!.remove(_userEmailKey);
      await _prefs!.remove(_userNameKey);
      await _prefs!.remove(_userRoleKey);
      await _prefs!.remove(_isLoggedInKey);
      await _prefs!.remove(_loginTimeKey);
      
      debugPrint('✅ Login data cleared from cache');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  static Future<String?> getCompanyCode() async {
    final data = await getLoginData();
    return data['companyCode'];
  }

  static Future<String?> getUserRole() async {
    final data = await getLoginData();
    return data['role'];
  }
}