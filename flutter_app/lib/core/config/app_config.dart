import 'package:shared_preferences/shared_preferences.dart';

/// 应用配置管理
/// 管理后端服务器地址等配置信息
class AppConfig {
  static const String _keyBaseUrl = 'base_url';
  static const String _keyInsecureSslHost = 'insecure_ssl_host';
  static const String _defaultBaseUrl = 'https://r-d.lengsu.top/';

  /// 默认后端服务器地址（供配置弹框「使用默认服务器」使用）
  static String get defaultBaseUrl => _defaultBaseUrl;

  /// 默认云阁的 host，对该 host 始终放宽 SSL 校验（解决浏览器可访问而 App 证书校验失败）
  static String? get defaultBaseUrlHost => Uri.tryParse(_defaultBaseUrl)?.host;

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

  /// 获取“不校验 SSL”的主机（仅对该 host 放宽证书校验，用于浏览器可访问但 App 报证书错误的场景）
  static Future<String?> getInsecureSslHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyInsecureSslHost);
  }

  /// 设置“不校验 SSL”的主机，传 null 表示关闭
  static Future<bool> setInsecureSslHost(String? host) async {
    final prefs = await SharedPreferences.getInstance();
    if (host == null || host.isEmpty) {
      return await prefs.remove(_keyInsecureSslHost);
    }
    return await prefs.setString(_keyInsecureSslHost, host);
  }

  /// 从 URL 解析 host（用于和当前云阁地址对比）
  static String? hostFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isEmpty ? null : uri.host;
    } catch (_) {
      return null;
    }
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
