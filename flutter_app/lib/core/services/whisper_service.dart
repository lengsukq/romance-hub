import 'package:romance_hub_flutter/core/constants/api_endpoints.dart';
import 'package:romance_hub_flutter/core/models/api_response.dart';
import 'package:romance_hub_flutter/core/models/whisper_model.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 留言服务
class WhisperService {
  final ApiService _apiService = ApiService();

  /// 获取我的留言列表
  Future<ApiResponse<List<WhisperModel>>> getMyWhisperList({String? searchWords}) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.whisper,
        data: {
          'action': 'mylist',
          'data': {'searchWords': searchWords ?? ''},
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<List<WhisperModel>>.fromJson(
        responseData,
        (data) {
          if (data is! List) return <WhisperModel>[];
          return data
              .map((item) => WhisperModel.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      AppLogger.e('获取我的留言列表失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取我的留言列表失败: ${e.toString()}',
      );
    }
  }

  /// 获取TA的留言列表
  Future<ApiResponse<List<WhisperModel>>> getTAWhisperList({String? searchWords}) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.whisper,
        data: {
          'action': 'talist',
          'data': {'searchWords': searchWords ?? ''},
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<List<WhisperModel>>.fromJson(
        responseData,
        (data) {
          if (data is! List) return <WhisperModel>[];
          return data
              .map((item) => WhisperModel.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      AppLogger.e('获取TA的留言列表失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取TA的留言列表失败: ${e.toString()}',
      );
    }
  }

  /// 创建留言
  Future<ApiResponse<void>> createWhisper({
    required String content,
    String? toUser,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.whisper,
        data: {
          'action': 'create',
          'data': {
            'content': content,
            'toUser': toUser,
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('创建留言失败', e);
      return ApiResponse(
        code: 500,
        msg: '创建留言失败: ${e.toString()}',
      );
    }
  }

  /// 删除留言（仅自己的留言）
  Future<ApiResponse<void>> deleteWhisper(int whisperId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.whisper,
        data: {
          'action': 'delete',
          'data': {'whisperId': whisperId},
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('删除留言失败', e);
      return ApiResponse(
        code: 500,
        msg: '删除留言失败: ${e.toString()}',
      );
    }
  }
}
