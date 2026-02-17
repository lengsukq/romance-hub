import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/models/task_model.dart';
import 'package:romance_hub_flutter/core/services/task_service.dart';
import 'package:romance_hub_flutter/core/constants/classic_verses.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/task_card.dart';
import 'package:romance_hub_flutter/shared/widgets/empty_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/year_2026_badge.dart';

/// 任务列表页面
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TaskService _taskService = TaskService();
  final ScrollController _scrollController = ScrollController();
  
  List<TaskModel> _taskList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;
  String? _taskStatus;
  String _searchWords = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _hasMore) {
        _loadMoreTasks();
      }
    }
  }

  Future<void> _loadTasks({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _taskList.clear();
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _taskService.getTaskList(
        current: _currentPage,
        pageSize: _pageSize,
        taskStatus: _taskStatus,
        searchWords: _searchWords.isEmpty ? null : _searchWords,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          if (refresh) {
            _taskList = response.data!.record;
          } else {
            _taskList.addAll(response.data!.record);
          }
          _hasMore = _currentPage < response.data!.totalPages;
          _isLoading = false;
        });
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
      AppLogger.e('加载任务列表失败', e);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('加载失败，请重试')),
        );
      }
    }
  }

  Future<void> _loadMoreTasks() async {
    if (!_hasMore || _isLoading) return;
    _currentPage++;
    await _loadTasks();
  }

  void _onTaskStatusChanged(String? status) {
    setState(() {
      _taskStatus = status;
    });
    _loadTasks(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Year2026Badge(label: '2026', large: false),
            const SizedBox(width: 10),
            Text('心诺', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go(AppRoutes.postTask),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip(context, '全部', null),
                _buildStatusChip(context, '待接受', 'pending'),
                _buildStatusChip(context, '进行中', 'accepted'),
                _buildStatusChip(context, '已完成', 'completed'),
              ],
            ),
          ),
        ),
      ),
      body: _taskList.isEmpty && !_isLoading
          ? const EmptyWidget(message: '暂无心诺', verse: ClassicVerses.caiGe)
          : RefreshIndicator(
              onRefresh: () => _loadTasks(refresh: true),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _taskList.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _taskList.length) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: colorScheme.primary),
                      ),
                    );
                  }
                  return TaskCard(
                    task: _taskList[index],
                    onTap: () => context.go(AppRoutes.taskDetail(_taskList[index].taskId)),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String label, String? status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _taskStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _onTaskStatusChanged(status);
        } else {
          _onTaskStatusChanged(null);
        }
      },
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _searchWords);
        return AlertDialog(
          title: const Text('寻诺'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '输入关键词',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchWords = controller.text;
                });
                Navigator.pop(context);
                _loadTasks(refresh: true);
              },
              child: const Text('搜索'),
            ),
          ],
        );
      },
    );
  }
}
