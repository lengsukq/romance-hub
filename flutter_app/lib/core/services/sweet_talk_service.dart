import 'package:dio/dio.dart';
import 'package:romance_hub_flutter/core/constants/api_endpoints.dart';
import 'package:romance_hub_flutter/core/models/api_response.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 情话服务：复用 Web 端后端代理 /api/v1/sweet-talk，避免 App 直连外部接口。
class SweetTalkService {
  SweetTalkService._();
  static final SweetTalkService instance = SweetTalkService._();
  final ApiService _apiService = ApiService();

  /// 获取一句情话。失败时返回 null，调用方可显示默认文案或隐藏。
  Future<String?> fetchOne() async {
    try {
      final response = await _apiService.get(ApiEndpoints.sweetTalk);
      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) return null;
      final apiResponse = ApiResponse<String>.fromJson(
        responseData,
        (data) => data?.toString() ?? '',
      );
      final text = apiResponse.data?.trim();
      return apiResponse.isSuccess && text != null && text.isNotEmpty
          ? text
          : null;
    } on DioException catch (e) {
      AppLogger.e('获取今日一言失败', e);
      return null;
    } catch (e) {
      AppLogger.e('解析今日一言失败', e);
      return null;
    }
  }
}
