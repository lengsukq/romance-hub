import 'package:dio/dio.dart';
import 'package:romance_hub_flutter/core/constants/api_endpoints.dart';
import 'package:romance_hub_flutter/core/models/api_response.dart';
import 'package:romance_hub_flutter/core/models/task_model.dart';
import 'package:romance_hub_flutter/core/services/api_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';

/// 任务服务
class TaskService {
  final ApiService _apiService = ApiService();

  /// 获取任务列表
  Future<ApiResponse<TaskListResponse>> getTaskList({
    int current = 1,
    int pageSize = 10,
    String? taskStatus,
    String? searchWords,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.task,
        data: {
          'action': 'list',
          'data': {
            'current': current,
            'pageSize': pageSize,
            'taskStatus': taskStatus,
            'searchWords': searchWords ?? '',
          },
        },
      );

      final responseData = response.data;
      if (responseData is! Map<String, dynamic>) {
        AppLogger.e('获取任务列表失败', '响应格式异常: 非 JSON 对象');
        return ApiResponse(code: 500, msg: '响应格式异常，请检查云阁地址');
      }
      final parsed = ApiResponse<TaskListResponse>.fromJson(
        responseData,
        (data) {
          if (data == null || data is! Map<String, dynamic>) {
            return TaskListResponse(record: [], totalPages: 0);
          }
          return TaskListResponse.fromJson(data);
        },
      );
      if (!parsed.isSuccess && parsed.msg.isNotEmpty) {
        AppLogger.d('获取任务列表: ${parsed.msg}');
      }
      return parsed;
    } on DioException catch (e) {
      final msg = _dioErrorMessage(e);
      AppLogger.e('获取任务列表失败', e);
      return ApiResponse(code: e.response?.statusCode ?? 500, msg: msg);
    } catch (e, stack) {
      AppLogger.e('获取任务列表失败', e);
      AppLogger.d(stack.toString());
      return ApiResponse(
        code: 500,
        msg: '获取任务列表失败: ${e.toString()}',
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
      case DioExceptionType.badCertificate:
        return '证书校验失败，可在设置中信任此云阁';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) return '请先登录';
        return '请求失败: ${e.response?.statusCode}';
      default:
        return e.message ?? '网络请求失败';
    }
  }

  /// 获取任务详情
  Future<ApiResponse<TaskModel>> getTaskDetail(int taskId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.task,
        data: {
          'action': 'detail',
          'data': {'taskId': taskId},
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<TaskModel>.fromJson(
        responseData,
        (data) => TaskModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      AppLogger.e('获取任务详情失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取任务详情失败: ${e.toString()}',
      );
    }
  }

  /// 发布任务
  Future<ApiResponse<void>> createTask({
    required String taskName,
    required String taskDesc,
    required List<String> taskImage,
    required int taskScore,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.task,
        data: {
          'action': 'create',
          'data': {
            'taskName': taskName,
            'taskDesc': taskDesc,
            'taskImage': taskImage,
            'taskScore': taskScore,
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('发布任务失败', e);
      return ApiResponse(
        code: 500,
        msg: '发布任务失败: ${e.toString()}',
      );
    }
  }

  /// 更新任务状态（与后端一致：taskStatus 为字符串 pending/accepted/completed）
  Future<ApiResponse<void>> updateTaskState({
    required int taskId,
    required String taskStatus,
  }) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.task,
        data: {
          'action': 'update',
          'data': {
            'taskId': taskId,
            'taskStatus': taskStatus,
          },
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('更新任务状态失败', e);
      return ApiResponse(
        code: 500,
        msg: '更新任务状态失败: ${e.toString()}',
      );
    }
  }

  /// 删除任务
  Future<ApiResponse<void>> deleteTask(int taskId) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.task,
        data: {
          'action': 'delete',
          'data': {'taskId': taskId},
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<void>.fromJson(responseData, null);
    } catch (e) {
      AppLogger.e('删除任务失败', e);
      return ApiResponse(
        code: 500,
        msg: '删除任务失败: ${e.toString()}',
      );
    }
  }
}
