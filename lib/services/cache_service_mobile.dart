// import 'package:shared_preferences/shared_preferences.dart';

// class CachePlatform {
//   static Future<void> saveData(Map<String, String> data) async {
//     final prefs = await SharedPreferences.getInstance();
//     data.forEach((key, value) => prefs.setString(key, value));
//   }

//   static Future<Map<String, String?>> getData(List<String> keys) async {
//     final prefs = await SharedPreferences.getInstance();
//     return {for (var k in keys) k: prefs.getString(k)};
//   }

//   static Future<void> clearData(List<String> keys) async {
//     final prefs = await SharedPreferences.getInstance();
//     for (var k in keys) {
//       await prefs.remove(k);
//     }
//   }
// }
