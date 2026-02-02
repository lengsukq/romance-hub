import 'package:romance_hub_flutter/core/constants/api_endpoints.dart';
import 'package:romance_hub_flutter/core/models/api_response.dart';
import 'package:romance_hub_flutter/core/models/image_bed_model.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 配置服务：图床等（与关联者共用）
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
}
