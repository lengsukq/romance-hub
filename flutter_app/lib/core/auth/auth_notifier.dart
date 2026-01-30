import 'package:flutter/foundation.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';

/// 登录状态通知：401 或主动退出时调用 [invalidate]，触发路由重定向到登录页
class AuthNotifier extends ChangeNotifier {
  /// Cookie 失效或用户退出时调用，清除本地 cookie 并通知路由重算
  Future<void> invalidate() async {
    await ApiService().clearCookie();
    notifyListeners();
  }

  /// 仅通知路由重算（例如 401 时 ApiService 已清 cookie，只需刷新路由）
  void refresh() {
    notifyListeners();
  }
}
