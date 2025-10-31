// // services/cache_service.dart
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//       import 'dart:html' as html;
   
// class CacheService {
//   static final CacheService _instance = CacheService._internal();
//   factory CacheService() => _instance;
//   CacheService._internal();

//   static const String _companyCodeKey = 'company_code';
//   static const String _userEmailKey = 'user_email';
//   static const String _userNameKey = 'user_name';
//   static const String _userRoleKey = 'user_role';
//   static const String _isLoggedInKey = 'is_logged_in';
//   static const String _loginTimeKey = 'login_time';

//   static SharedPreferences? _prefs;
//   static bool _initialized = false;

//   // 🔹 Initialize Shared Preferences with error handling
//   static Future<void> _ensureInitialized() async {
//     if (_initialized) return;
    
//     try {
//       _prefs = await SharedPreferences.getInstance();
//       _initialized = true;
//     } catch (e) {
//       if (kDebugMode) {
//         print('SharedPreferences initialization error: $e');
//       }
//       // For web, we'll use a fallback mechanism
//       _initialized = true;
//     }
//   }

//   // 🔹 Save login data with web fallback
//   static Future<void> saveLoginData({
//     required String companyCode,
//     required String email,
//     required String name,
//     required String role,
//   }) async {
//     await _ensureInitialized();
    
//     if (_prefs != null) {
//       await _prefs!.setString(_companyCodeKey, companyCode);
//       await _prefs!.setString(_userEmailKey, email);
//       await _prefs!.setString(_userNameKey, name);
//       await _prefs!.setString(_userRoleKey, role);
//       await _prefs!.setBool(_isLoggedInKey, true);
//       await _prefs!.setString(_loginTimeKey, DateTime.now().toIso8601String());
//     } else {
//       // Web fallback - use localStorage through dart:html
//       if (kIsWeb) {
//         _saveToWebStorage(companyCode, email, name, role);
//       }
//     }
//   }

//   // 🔹 Web storage fallback
//   static void _saveToWebStorage(String companyCode, String email, String name, String role) {
//     try {
   
//       html.window.localStorage[_companyCodeKey] = companyCode;
//       html.window.localStorage[_userEmailKey] = email;
//       html.window.localStorage[_userNameKey] = name;
//       html.window.localStorage[_userRoleKey] = role;
//       html.window.localStorage[_isLoggedInKey] = 'true';
//       html.window.localStorage[_loginTimeKey] = DateTime.now().toIso8601String();
//     } catch (e) {
//       if (kDebugMode) {
//         print('Web storage error: $e');
//       }
//     }
//   }

//   // 🔹 Get login data with web fallback
//   static Future<Map<String, String?>> getLoginData() async {
//     await _ensureInitialized();
    
//     if (_prefs != null) {
//       return {
//         'companyCode': _prefs!.getString(_companyCodeKey),
//         'email': _prefs!.getString(_userEmailKey),
//         'name': _prefs!.getString(_userNameKey),
//         'role': _prefs!.getString(_userRoleKey),
//         'isLoggedIn': _prefs!.getBool(_isLoggedInKey)?.toString(),
//         'loginTime': _prefs!.getString(_loginTimeKey),
//       };
//     } else if (kIsWeb) {
//       return _getFromWebStorage();
//     }
    
//     return {};
//   }

//   // 🔹 Web storage getter
//   static Map<String, String?> _getFromWebStorage() {
//     try {
//       return {
//         'companyCode': html.window.localStorage[_companyCodeKey],
//         'email': html.window.localStorage[_userEmailKey],
//         'name': html.window.localStorage[_userNameKey],
//         'role': html.window.localStorage[_userRoleKey],
//         'isLoggedIn': html.window.localStorage[_isLoggedInKey],
//         'loginTime': html.window.localStorage[_loginTimeKey],
//       };
//     } catch (e) {
//       if (kDebugMode) {
//         print('Web storage read error: $e');
//       }
//       return {};
//     }
//   }

//   // 🔹 Check if user is logged in
//   static Future<bool> isLoggedIn() async {
//     await _ensureInitialized();
    
//     if (_prefs != null) {
//       return _prefs!.getBool(_isLoggedInKey) ?? false;
//     } else if (kIsWeb) {
//       final data = _getFromWebStorage();
//       return data['isLoggedIn'] == 'true';
//     }
    
//     return false;
//   }

//   // 🔹 Clear login data (logout)
//   static Future<void> clearLoginData() async {
//     await _ensureInitialized();
    
//     if (_prefs != null) {
//       await _prefs!.remove(_companyCodeKey);
//       await _prefs!.remove(_userEmailKey);
//       await _prefs!.remove(_userNameKey);
//       await _prefs!.remove(_userRoleKey);
//       await _prefs!.remove(_isLoggedInKey);
//       await _prefs!.remove(_loginTimeKey);
//     } else if (kIsWeb) {
//       _clearWebStorage();
//     }
//   }

//   // 🔹 Web storage clear
//   static void _clearWebStorage() {
//     try {
//       html.window.localStorage.remove(_companyCodeKey);
//       html.window.localStorage.remove(_userEmailKey);
//       html.window.localStorage.remove(_userNameKey);
//       html.window.localStorage.remove(_userRoleKey);
//       html.window.localStorage.remove(_isLoggedInKey);
//       html.window.localStorage.remove(_loginTimeKey);
//     } catch (e) {
//       if (kDebugMode) {
//         print('Web storage clear error: $e');
//       }
//     }
//   }

//   // 🔹 Get company code
//   static Future<String?> getCompanyCode() async {
//     final data = await getLoginData();
//     return data['companyCode'];
//   }

//   // 🔹 Get user role
//   static Future<String?> getUserRole() async {
//     final data = await getLoginData();
//     return data['role'];
//   }
// }