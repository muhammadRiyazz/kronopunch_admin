import 'dart:html' as html;

class CachePlatform {
  static Future<void> saveData(Map<String, String> data) async {
    data.forEach((key, value) => html.window.localStorage[key] = value);
  }

  static Future<Map<String, String?>> getData(List<String> keys) async {
    return {for (var k in keys) k: html.window.localStorage[k]};
  }

  static Future<void> clearData(List<String> keys) async {
    for (var k in keys) {
      html.window.localStorage.remove(k);
    }
  }
}
