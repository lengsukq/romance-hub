import 'package:dio/dio.dart';
import 'package:romance_hub_flutter/core/constants/api_endpoints.dart';
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
        ApiEndpoints.favourite,
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
        ApiEndpoints.favourite,
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
        ApiEndpoints.favourite,
        data: {
          'action': 'list',
          'data': {'type': type.name},
        },
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        AppLogger.e('获取收藏列表失败', '响应格式异常: 非 JSON 对象');
        return ApiResponse(code: 500, msg: '响应格式异常，请检查云阁地址');
      }
      return ApiResponse<List<FavouriteModel>>.fromJson(
        responseData,
        (data) {
          if (data == null || data is! List) return <FavouriteModel>[];
          final list = <FavouriteModel>[];
          for (final e in data) {
            if (e is Map<String, dynamic>) {
              try {
                list.add(FavouriteModel.fromJson(e));
              } catch (err) {
                AppLogger.d('收藏项解析跳过: $err');
              }
            }
          }
          return list;
        },
      );
    } on DioException catch (e) {
      final msg = _dioErrorMessage(e);
      AppLogger.e('获取收藏列表失败', e);
      return ApiResponse(code: e.response?.statusCode ?? 500, msg: msg);
    } catch (e, stack) {
      AppLogger.e('获取收藏列表失败', e);
      AppLogger.d(stack.toString());
      return ApiResponse(
        code: 500,
        msg: '获取收藏列表失败: ${e.toString()}',
      );
    }
  }

  static String _dioErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final msg = e.response!.data['msg'];
      if (msg != null && msg.toString().isNotEmpty) return msg.toString();
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '网络超时，请检查云阁地址与网络';
      case DioExceptionType.connectionError:
        return '无法连接服务器，请检查云阁地址与网络';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) return '请先登录';
        return '请求失败: ${e.response?.statusCode}';
      default:
        return e.message ?? '网络请求失败';
    }
  }
}
