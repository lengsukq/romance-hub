import 'dart:io';
import 'package:dio/dio.dart';
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
        '/api/v1/common',
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

  /// 上传多张图片
  Future<ApiResponse<List<String>>> uploadImages(List<File> files) async {
    try {
      final formData = FormData();
      for (var file in files) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(file.path),
          ),
        );
      }

      final response = await _apiService.dio.post(
        '/api/v1/common',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<List<String>>.fromJson(
        responseData,
        (data) {
          if (data is List) {
            return data.map((item) => (item as Map<String, dynamic>)['url'] as String? ?? item.toString()).toList().cast<String>();
          }
          return [];
        },
      );
    } catch (e) {
      AppLogger.e('上传图片失败', e);
      return ApiResponse(
        code: 500,
        msg: '上传图片失败: ${e.toString()}',
      );
    }
  }
}
