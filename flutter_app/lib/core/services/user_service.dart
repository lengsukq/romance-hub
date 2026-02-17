import 'package:romance_hub_flutter/core/constants/api_endpoints.dart';
import 'package:romance_hub_flutter/core/models/api_response.dart';
import 'package:romance_hub_flutter/core/models/user_model.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 用户服务
class UserService {
  final ApiService _apiService = ApiService();

  /// 获取用户信息
  Future<ApiResponse<UserModel>> getUserInfo() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.user,
        data: {'action': 'info'},
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<UserModel>.fromJson(
        responseData,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      AppLogger.e('获取用户信息失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取用户信息失败: ${e.toString()}',
      );
    }
  }

  /// 获取关联者信息
  Future<ApiResponse<UserModel>> getLoverInfo() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.user,
        data: {'action': 'lover'},
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<UserModel>.fromJson(
        responseData,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      AppLogger.e('获取关联者信息失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取关联者信息失败: ${e.toString()}',
      );
    }
  }

  /// 更新用户信息
  Future<ApiResponse<void>> updateUserInfo({
    String? username,
    String? avatar,
    String? describeBySelf,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.user,
        data: {
          'action': 'update',
          'data': {
            'username': username,
            'avatar': avatar,
            'describeBySelf': describeBySelf,
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('更新用户信息失败', e);
      return ApiResponse(
        code: 500,
        msg: '更新用户信息失败: ${e.toString()}',
      );
    }
  }

  /// 获取积分
  Future<ApiResponse<int>> getScore() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.user,
        data: {'action': 'score'},
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<int>.fromJson(
        responseData,
        (data) {
          if (data == null) return 0;
          if (data is int) return data;
          if (data is Map && data['score'] != null) return (data['score'] as num).toInt();
          return 0;
        },
      );
    } catch (e) {
      AppLogger.e('获取积分失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取积分失败: ${e.toString()}',
      );
    }
  }

  /// 退出登录
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.user,
        data: {'action': 'logout'},
      );

      await _apiService.clearCookie();
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('退出登录失败', e);
      return ApiResponse(
        code: 500,
        msg: '退出登录失败: ${e.toString()}',
      );
    }
  }
}
