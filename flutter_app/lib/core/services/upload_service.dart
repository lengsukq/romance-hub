import 'dart:io';
import 'package:dio/dio.dart';
import 'package:romance_hub_flutter/core/constants/api_endpoints.dart';
import 'package:romance_hub_flutter/core/models/api_response.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 文件上传服务
class UploadService {
  final ApiService _apiService = ApiService();

  /// 上传图片
  Future<ApiResponse<String>> uploadImage(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
      });

      final response = await _apiService.dio.post(
        ApiEndpoints.common,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final responseData = response.data as Map<String, dynamic>;
      final apiResponse = ApiResponse<String>.fromJson(
        responseData,
        (data) => (data as Map<String, dynamic>)['url'] as String? ?? data.toString(),
      );

      return apiResponse;
    } catch (e) {
      AppLogger.e('上传图片失败', e);
      return ApiResponse(
        code: 500,
        msg: '上传图片失败: ${e.toString()}',
      );
    }
  }

  /// 上传多张图片（后端单次只支持单文件，逐张上传）
  Future<ApiResponse<List<String>>> uploadImages(List<File> files) async {
    final List<String> urls = [];
    for (final file in files) {
      final res = await uploadImage(file);
      if (!res.isSuccess || res.data == null || res.data!.isEmpty) {
        return ApiResponse(
          code: res.code,
          msg: res.msg.isNotEmpty ? res.msg : '第${urls.length + 1}张图片上传失败',
          data: null,
        );
      }
      urls.add(res.data!);
    }
    return ApiResponse(code: 200, msg: '上传成功', data: urls);
  }
}
