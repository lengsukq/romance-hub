import 'package:dio/dio.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/constants/api_endpoints.dart';
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
        ApiEndpoints.user,
        data: {
          'action': 'login',
          'data': {
            'username': username,
            'password': password,
          },
        },
      );

      final raw = response.data;
      if (raw == null || raw is! Map<String, dynamic>) {
        AppLogger.e('登录失败', '响应格式异常: ${raw.runtimeType}');
        return ApiResponse(code: 500, msg: '云阁响应格式异常，请检查地址是否正确');
      }

      final code = (raw['code'] is int) ? raw['code'] as int : 500;
      final msg = (raw['msg'] is String) ? raw['msg'] as String : '未知错误';
      UserModel? userData;
      if (code == 200 && raw['data'] != null && raw['data'] is Map<String, dynamic>) {
        try {
          userData = UserModel.fromJson(raw['data'] as Map<String, dynamic>);
        } catch (e) {
          AppLogger.e('解析用户信息失败', e);
          return ApiResponse(code: 500, msg: '云阁返回数据格式异常');
        }
      }

      final apiResponse = ApiResponse<UserModel>(code: code, msg: msg, data: userData);

      if (apiResponse.isSuccess && apiResponse.data != null) {
        // 保存所有 cookie（服务端 middleware 需要 cookie=JSON 与 name=JWT 两个 cookie）
        final raw = response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
        List<String> list = raw != null ? List<String>.from(raw as List) : <String>[];
        if (list.length == 1 && list[0].contains(', ')) {
          list = list[0].split(', ').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
        final parts = list
            .map((v) => v.contains(';') ? v.split(';').first.trim() : v.trim())
            .where((s) => s.isNotEmpty);
        if (parts.isNotEmpty) {
          await _apiService.saveCookie(parts.join('; '));
        }
      }

      return apiResponse;
    } on DioException catch (e) {
      final baseUrl = await AppConfig.getBaseUrl();
      final msg = _loginDioErrorMessage(e, baseUrl);
      AppLogger.e('登录失败 baseUrl=$baseUrl', e);
      return ApiResponse(code: 500, msg: msg);
    } catch (e, stack) {
      AppLogger.e('登录失败', e);
      AppLogger.d('堆栈: $stack');
      return ApiResponse(
        code: 500,
        msg: '登录失败: ${e.toString()}',
      );
    }
  }

  String _loginDioErrorMessage(DioException e, String baseUrl) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return '无法连接云阁（当前地址: $baseUrl），请检查网络与云阁地址';
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return '连接超时，请稍后重试';
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) return '用户名或密码错误';
        if (code != null && code >= 500) return '云阁繁忙，请稍后重试';
        return e.response?.data is Map ? (e.response!.data['msg'] as String? ?? '请求失败') : '请求失败';
      case DioExceptionType.cancel:
        return '请求已取消';
      default:
        return '网络异常: ${e.message ?? e.type.name}';
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
        ApiEndpoints.user,
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
