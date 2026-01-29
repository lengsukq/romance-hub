import 'package:romance_hub_flutter/core/models/api_response.dart';
import 'package:romance_hub_flutter/core/models/user_model.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 认证服务
class AuthService {
  final ApiService _apiService = ApiService();

  /// 用户登录
  Future<ApiResponse<UserModel>> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        '/api/v1/user',
        data: {
          'action': 'login',
          'data': {
            'username': username,
            'password': password,
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      final apiResponse = ApiResponse<UserModel>.fromJson(
        responseData,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (apiResponse.isSuccess && apiResponse.data != null) {
        // 保存 cookie（从响应头获取）
        final setCookieHeaders = response.headers['set-cookie'];
        if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
          await _apiService.saveCookie(setCookieHeaders.first);
        }
      }

      return apiResponse;
    } catch (e) {
      AppLogger.e('登录失败', e);
      return ApiResponse(
        code: 500,
        msg: '登录失败: ${e.toString()}',
      );
    }
  }

  /// 双账号注册（与 Web 端接口一致）
  Future<ApiResponse<void>> register({
    required String userEmail,
    required String username,
    required String password,
    required String describeBySelf,
    required String lover,
    required String loverUsername,
    required String loverDescribeBySelf,
    String? avatar,
    String? loverAvatar,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/v1/user',
        data: {
          'action': 'register',
          'data': {
            'userEmail': userEmail,
            'username': username,
            'password': password,
            'describeBySelf': describeBySelf,
            'lover': lover,
            'avatar': avatar,
            'loverUsername': loverUsername,
            'loverAvatar': loverAvatar,
            'loverDescribeBySelf': loverDescribeBySelf,
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(
        responseData,
        (_) => null,
      );
    } catch (e) {
      AppLogger.e('注册失败', e);
      return ApiResponse(
        code: 500,
        msg: '注册失败: ${e.toString()}',
      );
    }
  }

  /// 退出登录
  Future<void> logout() async {
    await _apiService.clearCookie();
  }
}
