import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/models/task_model.dart';
import 'package:romance_hub_flutter/core/services/task_service.dart';
import 'package:romance_hub_flutter/core/services/favourite_service.dart';
import 'package:romance_hub_flutter/core/services/user_service.dart';
import 'package:romance_hub_flutter/core/models/favourite_model.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/core/utils/date_utils.dart' as app_date_utils;
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/image_viewer.dart';
import 'package:romance_hub_flutter/shared/widgets/confirm_dialog.dart';

/// 任务详情页面
class TaskDetailPage extends StatefulWidget {
  final int taskId;

  const TaskDetailPage({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TaskService _taskService = TaskService();
  final FavouriteService _favouriteService = FavouriteService();
  final UserService _userService = UserService();
  TaskModel? _task;
  bool _isLoading = true;
  bool _isFavourite = false;
  String? _userEmail;
  bool _stateLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    _loadTaskDetail();
  }

  Future<void> _loadUserEmail() async {
    final res = await _userService.getUserInfo();
    if (res.isSuccess && res.data != null && mounted) {
      setState(() => _userEmail = res.data!.userEmail);
    }
  }

  Future<void> _loadTaskDetail() async {
    try {
      final response = await _taskService.getTaskDetail(widget.taskId);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _task = response.data;
          _isLoading = false;
        });
        // 检查是否已收藏
        _checkFavourite();
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg)),
          );
        }
      }
    } catch (e) {
      AppLogger.e('加载任务详情失败', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkFavourite() async {
    // 这里应该从任务详情中获取 favId，如果存在则已收藏
    // 由于 API 响应可能包含 favId，这里简化处理
  }

  Future<void> _toggleFavourite() async {
    try {
      if (_isFavourite) {
        final response = await _favouriteService.removeFavourite(
          collectionId: widget.taskId,
          collectionType: FavouriteType.task,
        );
        if (response.isSuccess) {
          setState(() {
            _isFavourite = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已取消收藏')),
            );
          }
        }
      } else {
        final response = await _favouriteService.addFavourite(
          collectionId: widget.taskId,
          collectionType: FavouriteType.task,
        );
        if (response.isSuccess) {
          setState(() {
            _isFavourite = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已添加收藏')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg)),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.e('收藏操作失败', e);
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await ConfirmDialog.show(
      context,
      title: '确认删除',
      message: '确定要删除此心诺吗？',
      confirmText: '确定',
      cancelText: '取消',
    );

    if (confirm == true) {
      try {
        final response = await _taskService.deleteTask(widget.taskId);
        if (response.isSuccess) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('删除成功')),
            );
            context.go(AppRoutes.tasks);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg)),
            );
          }
        }
      } catch (e) {
        AppLogger.e('删除任务失败', e);
      }
    }
  }

  Future<void> _acceptTask() async {
    if (_task == null || _stateLoading) return;
    setState(() => _stateLoading = true);
    final res = await _taskService.updateTaskState(taskId: _task!.taskId, taskStatus: 'accepted');
    if (mounted) {
      setState(() => _stateLoading = false);
      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已接受')));
        _loadTaskDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.msg)));
      }
    }
  }

  Future<void> _completeTask() async {
    if (_task == null || _stateLoading) return;
    setState(() => _stateLoading = true);
    final res = await _taskService.updateTaskState(taskId: _task!.taskId, taskStatus: 'completed');
    if (mounted) {
      setState(() => _stateLoading = false);
      if (res.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已完成')));
        _loadTaskDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res.msg)));
      }
    }
  }

  bool get _showAccept =>
      _userEmail != null &&
      _task != null &&
      _task!.taskStatus == 'pending' &&
      _task!.recipientId == _userEmail;

  bool get _showComplete =>
      _userEmail != null &&
      _task != null &&
      _task!.taskStatus == 'accepted' &&
      (_task!.recipientId == _userEmail || _task!.publisherId == _userEmail);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (_isLoading) {
      return const Scaffold(body: LoadingWidget());
    }

    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('心诺详情')),
        body: Center(
          child: Text(
            '心诺不存在',
            style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('心诺详情'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
            color: _isFavourite ? colorScheme.primary : colorScheme.onSurfaceVariant,
            onPressed: _toggleFavourite,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded, color: colorScheme.onSurfaceVariant),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _task!.taskName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            if (_task!.taskDesc != null && _task!.taskDesc!.isNotEmpty) ...[
              Text(
                _task!.taskDesc!,
                style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
            ],
            if (_task!.taskImage.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _task!.taskImage.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ImageViewer(
                                images: _task!.taskImage,
                                initialIndex: index,
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            _task!.taskImage[index],
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 200,
                                height: 200,
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(Icons.image_not_supported_rounded, color: colorScheme.onSurfaceVariant),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildInfoRow(context, '发布者', _task!.publisherName),
            _buildInfoRow(context, '状态', _getStatusText(_task!.taskStatus)),
            if (_showAccept || _showComplete) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    if (_showAccept)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilledButton(
                          onPressed: _stateLoading ? null : _acceptTask,
                          child: const Text('接受'),
                        ),
                      ),
                    if (_showComplete)
                      FilledButton.tonal(
                        onPressed: _stateLoading ? null : _completeTask,
                        child: const Text('完成任务'),
                      ),
                  ],
                ),
              ),
            ],
            _buildInfoRow(context, '积分', '${_task!.taskScore}'),
            _buildInfoRow(context, '创建时间', app_date_utils.DateUtils.formatDateTimeDisplay(_task!.creationTime)),
            if (_task!.completionTime != null)
              _buildInfoRow(context, '完成时间', app_date_utils.DateUtils.formatDateTimeDisplay(_task!.completionTime)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return '待接受';
      case 'accepted':
        return '进行中';
      case 'completed':
        return '已完成';
      default:
        return status;
    }
  }
}
