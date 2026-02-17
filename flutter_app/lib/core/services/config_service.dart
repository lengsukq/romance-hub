import 'package:romance_hub_flutter/core/constants/api_endpoints.dart';
import 'package:romance_hub_flutter/core/models/api_response.dart';
import 'package:romance_hub_flutter/core/models/image_bed_model.dart';
import 'package:romance_hub_flutter/core/models/notification_config_model.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 配置服务：图床、通知、系统配置（与关联者共用，与 Web 端对齐）
class ConfigService {
  final ApiService _apiService = ApiService();

  /// 获取图床配置列表（含与良人共用的默认图床）
  Future<ApiResponse<List<ImageBedModel>>> getImageBeds() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.config,
        data: {'action': 'get_image_beds'},
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<List<ImageBedModel>>.fromJson(
        responseData,
        (data) {
          if (data is! List) return <ImageBedModel>[];
          return data
              .map((e) => ImageBedModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      AppLogger.e('获取图床配置失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取图床配置失败: ${e.toString()}',
      );
    }
  }

  /// 更新/新增图床配置（后端会同步到关联者）
  Future<ApiResponse<void>> updateImageBed({
    required String bedName,
    required String bedType,
    required String apiUrl,
    String? apiKey,
    String? authHeader,
    bool isActive = true,
    bool isDefault = false,
    int priority = 0,
    String? description,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.config,
        data: {
          'action': 'update_image_bed',
          'data': {
            'bedName': bedName,
            'bedType': bedType,
            'apiUrl': apiUrl,
            'apiKey': apiKey ?? '',
            'authHeader': authHeader ?? '',
            'isActive': isActive,
            'isDefault': isDefault,
            'priority': priority,
            'description': description ?? '',
          },
        },
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('更新图床配置失败', e);
      return ApiResponse(
        code: 500,
        msg: '更新图床配置失败: ${e.toString()}',
      );
    }
  }

  /// 获取通知配置列表
  Future<ApiResponse<List<NotificationConfigModel>>> getNotifications() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.config,
        data: {'action': 'get_notifications'},
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<List<NotificationConfigModel>>.fromJson(
        responseData,
        (data) {
          if (data is! List) return <NotificationConfigModel>[];
          return data
              .map((e) => NotificationConfigModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      AppLogger.e('获取通知配置失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取通知配置失败: ${e.toString()}',
      );
    }
  }

  /// 更新/新增通知配置（与良人共用）
  Future<ApiResponse<void>> updateNotification({
    required String notifyType,
    required String notifyName,
    String webhookUrl = '',
    String apiKey = '',
    String description = '',
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.config,
        data: {
          'action': 'update_notification',
          'data': {
            'notifyType': notifyType,
            'notifyName': notifyName,
            'webhookUrl': webhookUrl,
            'apiKey': apiKey,
            'description': description,
          },
        },
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('更新通知配置失败', e);
      return ApiResponse(
        code: 500,
        msg: '更新通知配置失败: ${e.toString()}',
      );
    }
  }

  /// 获取系统配置（如 WEB_URL）
  Future<ApiResponse<Map<String, String>>> getSystemConfigs() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.config,
        data: {'action': 'get_system_configs'},
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<Map<String, String>>.fromJson(
        responseData,
        (data) {
          if (data is! Map) return <String, String>{};
          return Map<String, String>.from(
            data.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
          );
        },
      );
    } catch (e) {
      AppLogger.e('获取系统配置失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取系统配置失败: ${e.toString()}',
      );
    }
  }

  /// 更新系统配置（如 WEB_URL，与良人共用）
  Future<ApiResponse<void>> updateSystemConfig({
    required String configKey,
    required String configValue,
    String configType = 'other',
    String description = '',
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.config,
        data: {
          'action': 'update_system_config',
          'data': {
            'configKey': configKey,
            'configValue': configValue,
            'configType': configType,
            'description': description,
          },
        },
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('更新系统配置失败', e);
      return ApiResponse(
        code: 500,
        msg: '更新系统配置失败: ${e.toString()}',
      );
    }
  }

  /// 初始化默认配置（与 Web 端一致）
  Future<ApiResponse<void>> initializeConfigs() async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.config,
        data: {'action': 'initialize_configs'},
      );
      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('初始化配置失败', e);
      return ApiResponse(
        code: 500,
        msg: '初始化配置失败: ${e.toString()}',
      );
    }
  }
}
