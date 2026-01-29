import 'package:shared_preferences/shared_preferences.dart';

/// 应用配置管理
/// 管理后端服务器地址等配置信息
class AppConfig {
  static const String _keyBaseUrl = 'base_url';
  static const String _defaultBaseUrl = 'https://r-d.lengsu.top/';

  /// 获取后端服务器地址
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyBaseUrl) ?? _defaultBaseUrl;
  }

  /// 设置后端服务器地址
  static Future<bool> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_keyBaseUrl, url);
  }

  /// 验证 URL 格式
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// 规范化 URL（确保以 / 结尾）
  static String normalizeUrl(String url) {
    if (url.isEmpty) return url;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
}
