import 'package:romance_hub_flutter/core/models/api_response.dart';
import 'package:romance_hub_flutter/core/models/favourite_model.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 收藏服务
class FavouriteService {
  final ApiService _apiService = ApiService();

  /// 添加收藏
  Future<ApiResponse<void>> addFavourite({
    required int collectionId,
    required FavouriteType collectionType,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/v1/favourite',
        data: {
          'action': 'add',
          'data': {
            'collectionId': collectionId,
            'collectionType': collectionType.name,
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('添加收藏失败', e);
      return ApiResponse(
        code: 500,
        msg: '添加收藏失败: ${e.toString()}',
      );
    }
  }

  /// 移除收藏
  Future<ApiResponse<void>> removeFavourite({
    required int collectionId,
    required FavouriteType collectionType,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/v1/favourite',
        data: {
          'action': 'remove',
          'data': {
            'collectionId': collectionId,
            'collectionType': collectionType.name,
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('移除收藏失败', e);
      return ApiResponse(
        code: 500,
        msg: '移除收藏失败: ${e.toString()}',
      );
    }
  }

  /// 获取收藏列表
  Future<ApiResponse<List<FavouriteModel>>> getFavouriteList(FavouriteType type) async {
    try {
      final response = await _apiService.post(
        '/api/v1/favourite',
        data: {
          'action': 'list',
          'data': {'type': type.name},
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<List<FavouriteModel>>.fromJson(
        responseData,
        (data) {
          if (data is! List) return <FavouriteModel>[];
          return data
              .map((item) => FavouriteModel.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      AppLogger.e('获取收藏列表失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取收藏列表失败: ${e.toString()}',
      );
    }
  }
}
