import 'package:romance_hub_flutter/core/models/api_response.dart';
import 'package:romance_hub_flutter/core/models/gift_model.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 礼物服务
class GiftService {
  final ApiService _apiService = ApiService();

  /// 获取礼物列表
  Future<ApiResponse<List<GiftModel>>> getGiftList({String? searchWords}) async {
    try {
      final response = await _apiService.post(
        '/api/v1/gift',
        data: {
          'action': 'list',
          'data': {'searchWords': searchWords ?? ''},
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<List<GiftModel>>.fromJson(
        responseData,
        (data) {
          if (data is! List) return <GiftModel>[];
          return data
              .map((item) => GiftModel.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      AppLogger.e('获取礼物列表失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取礼物列表失败: ${e.toString()}',
      );
    }
  }

  /// 获取我的礼物列表
  Future<ApiResponse<List<GiftModel>>> getMyGiftList({
    String? type,
    String? searchWords,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/v1/gift',
        data: {
          'action': 'mylist',
          'data': {
            'type': type,
            'searchWords': searchWords ?? '',
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<List<GiftModel>>.fromJson(
        responseData,
        (data) {
          if (data is! List) return <GiftModel>[];
          return data
              .map((item) => GiftModel.fromJson(item as Map<String, dynamic>))
              .toList();
        },
      );
    } catch (e) {
      AppLogger.e('获取我的礼物列表失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取我的礼物列表失败: ${e.toString()}',
      );
    }
  }

  /// 创建礼物
  Future<ApiResponse<void>> createGift({
    required String giftName,
    String? giftDesc,
    String? giftImage,
    required int score,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/v1/gift',
        data: {
          'action': 'create',
          'data': {
            'giftName': giftName,
            'giftDesc': giftDesc,
            'giftImage': giftImage,
            'score': score,
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('创建礼物失败', e);
      return ApiResponse(
        code: 500,
        msg: '创建礼物失败: ${e.toString()}',
      );
    }
  }

  /// 兑换礼物
  Future<ApiResponse<void>> exchangeGift(int giftId) async {
    try {
      final response = await _apiService.post(
        '/api/v1/gift',
        data: {
          'action': 'exchange',
          'data': {'giftId': giftId},
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('兑换礼物失败', e);
      return ApiResponse(
        code: 500,
        msg: '兑换礼物失败: ${e.toString()}',
      );
    }
  }

  /// 使用礼物
  Future<ApiResponse<void>> useGift(int giftId) async {
    try {
      final response = await _apiService.post(
        '/api/v1/gift',
        data: {
          'action': 'use',
          'data': {'giftId': giftId},
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('使用礼物失败', e);
      return ApiResponse(
        code: 500,
        msg: '使用礼物失败: ${e.toString()}',
      );
    }
  }

  /// 上架/下架礼物
  Future<ApiResponse<void>> toggleGiftShow({
    required int giftId,
    required bool isShow,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/v1/gift',
        data: {
          'action': 'show',
          'data': {
            'giftId': giftId,
            'isShow': isShow,
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('更新礼物状态失败', e);
      return ApiResponse(
        code: 500,
        msg: '更新礼物状态失败: ${e.toString()}',
      );
    }
  }
}
