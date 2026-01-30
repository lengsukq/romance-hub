import 'package:flutter/foundation.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';

/// 登录状态通知：缓存登录态，避免每次 redirect 都读存储导致误判
/// 401 或主动退出时调用 [invalidate]，触发路由重定向到登录页
class AuthNotifier extends ChangeNotifier {
  bool? _isLoggedIn;

  /// 是否已解析过登录态（避免每次 redirect 都 async 读存储）
  bool get isLoggedInKnown => _isLoggedIn != null;

  /// 当前是否视为已登录（未知时按未登录）
  bool get isLoggedIn => _isLoggedIn == true;

  /// 设置登录态（登录成功时设为 true，401/退出时由 refresh/invalidate 设为 false）
  void setLoggedIn(bool value) {
    if (_isLoggedIn == value) return;
    _isLoggedIn = value;
    notifyListeners();
  }

  /// Cookie 失效或用户退出时调用，清除本地 cookie 并置为未登录
  Future<void> invalidate() async {
    await ApiService().clearCookie();
    _isLoggedIn = false;
    notifyListeners();
  }

  /// 401 时 ApiService 已清 cookie，仅置为未登录并刷新路由
  void refresh() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
