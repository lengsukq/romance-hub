import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/models/task_model.dart';
import 'package:romance_hub_flutter/core/services/task_service.dart';
import 'package:romance_hub_flutter/core/services/favourite_service.dart';
import 'package:romance_hub_flutter/core/models/favourite_model.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
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
  TaskModel? _task;
  bool _isLoading = true;
  bool _isFavourite = false;
  int? _favId;

  @override
  void initState() {
    super.initState();
    _loadTaskDetail();
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
            _favId = null;
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
      message: '确定要删除这个任务吗？',
      confirmText: '确定',
      cancelText: '取消',
      confirmColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }

    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('任务详情')),
        body: const Center(child: Text('任务不存在')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('任务详情'),
        actions: [
          IconButton(
            icon: Icon(_isFavourite ? Icons.favorite : Icons.favorite_border),
            color: _isFavourite ? Colors.red : null,
            onPressed: _toggleFavourite,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _task!.taskName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_task!.taskDesc != null && _task!.taskDesc!.isNotEmpty) ...[
              Text(
                _task!.taskDesc!,
                style: const TextStyle(fontSize: 16),
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
                      padding: const EdgeInsets.only(right: 8.0),
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
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _task!.taskImage[index],
                            width: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
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
            _buildInfoRow('发布者', _task!.publisherName),
            _buildInfoRow('状态', _getStatusText(_task!.taskStatus)),
            _buildInfoRow('积分', '${_task!.taskScore}'),
            _buildInfoRow('创建时间', _task!.creationTime),
            if (_task!.completionTime != null)
              _buildInfoRow('完成时间', _task!.completionTime!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
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
