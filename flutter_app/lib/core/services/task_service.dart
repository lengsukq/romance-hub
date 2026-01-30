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

      final responseData = response.data as Map<String, dynamic>;
      return ApiResponse<TaskListResponse>.fromJson(
        responseData,
        (data) {
          if (data is! Map<String, dynamic>) {
            return TaskListResponse(record: [], totalPages: 0);
          }
          return TaskListResponse.fromJson(data);
        },
      );
    } catch (e) {
      AppLogger.e('获取任务列表失败', e);
      return ApiResponse(
        code: 500,
        msg: '获取任务列表失败: ${e.toString()}',
      );
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

  /// 更新任务状态
  Future<ApiResponse<void>> updateTaskStatus({
    required int taskId,
    required int taskStatus,
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
