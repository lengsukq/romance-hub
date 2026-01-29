/// 验证工具类
class ValidationUtils {
  /// 验证邮箱格式
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
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

  /// 验证密码强度（至少6位）
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  /// 验证用户名（至少3位，只能包含字母、数字、下划线）
  static bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]{3,}$');
    return usernameRegex.hasMatch(username);
  }
}
