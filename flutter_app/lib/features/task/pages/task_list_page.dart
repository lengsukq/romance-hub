import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/models/task_model.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/services/task_service.dart';
import 'package:romance_hub_flutter/core/theme/app_spacing.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/adaptive_masonry_grid.dart';
import 'package:romance_hub_flutter/shared/widgets/app_page_container.dart';
import 'package:romance_hub_flutter/shared/widgets/empty_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/list_display_mode_toggle.dart';
import 'package:romance_hub_flutter/shared/widgets/task_card.dart';
import 'package:romance_hub_flutter/shared/widgets/year_2026_badge.dart';

/// 心诺列表：Wrap 筛选 chip，Pad 限宽居中。
class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TaskService _taskService = TaskService();
  final ScrollController _scrollController = ScrollController();
  static const _statusFilters = [
    _TaskStatusFilter('全部', null),
    _TaskStatusFilter('待接受', 'pending'),
    _TaskStatusFilter('进行中', 'accepted'),
    _TaskStatusFilter('已完成', 'completed'),
  ];

  List<TaskModel> _taskList = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;
  String? _taskStatus;
  String _searchWords = '';
  ListDisplayMode _displayMode = ListDisplayMode.card;

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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
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
    setState(() => _isLoading = true);

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
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.msg)));
        }
      }
    } catch (e) {
      AppLogger.e('加载任务列表失败', e);
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('加载失败，请重试')));
      }
    }
  }

  Future<void> _loadMoreTasks() async {
    if (!_hasMore || _isLoading) return;
    _currentPage++;
    await _loadTasks();
  }

  void _onTaskStatusChanged(String? status) {
    if (_taskStatus == status) return;
    setState(() => _taskStatus = status);
    _loadTasks(refresh: true);
  }

  String get _selectedStatusLabel {
    return _statusFilters
        .firstWhere(
          (filter) => filter.status == _taskStatus,
          orElse: () => _statusFilters.first,
        )
        .label;
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
            const SizedBox(width: AppSpacing.md),
            Text(
              '心诺',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          ListDisplayModeToggle(
            mode: _displayMode,
            onChanged: (mode) => setState(() => _displayMode = mode),
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go(AppRoutes.postTask),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: _buildStatusSelector(context),
          ),
        ),
      ),
      body: _taskList.isEmpty && !_isLoading
          ? const EmptyWidget(message: '暂无心诺')
          : RefreshIndicator(
              onRefresh: () => _loadTasks(refresh: true),
              child: AppPageContainer(
                child: _displayMode == ListDisplayMode.card
                    ? _buildCardList(colorScheme)
                    : _buildWaterfallList(colorScheme),
              ),
            ),
    );
  }

  Widget _buildCardList(ColorScheme colorScheme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      itemCount: _taskList.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _taskList.length) return _buildLoadingMore(colorScheme);
        return TaskCard(
          task: _taskList[index],
          onTap: () =>
              context.go(AppRoutes.taskDetail(_taskList[index].taskId)),
        );
      },
    );
  }

  Widget _buildWaterfallList(ColorScheme colorScheme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: AdaptiveMasonryGrid(
        itemCount: _taskList.length + (_hasMore ? 1 : 0),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemBuilder: (context, index) {
          if (index == _taskList.length) return _buildLoadingMore(colorScheme);
          return TaskCard(
            task: _taskList[index],
            compact: true,
            onTap: () =>
                context.go(AppRoutes.taskDetail(_taskList[index].taskId)),
          );
        },
      ),
    );
  }

  Widget _buildLoadingMore(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: CircularProgressIndicator(color: colorScheme.primary),
      ),
    );
  }

  Widget _buildStatusSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: _showStatusFilterSheet,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.24),
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(Icons.tune_rounded, size: 18, color: colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '筛选',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                _selectedStatusLabel,
                textAlign: TextAlign.right,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusFilterSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: Text(
                  '筛选心诺状态',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ..._statusFilters.map((filter) {
                final isSelected = _taskStatus == filter.status;
                return ListTile(
                  title: Text(filter.label),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded, color: colorScheme.primary)
                      : null,
                  selected: isSelected,
                  selectedColor: colorScheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    _onTaskStatusChanged(filter.status);
                  },
                );
              }),
            ],
          ),
        ),
      ),
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
            decoration: const InputDecoration(hintText: '输入关键词'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _searchWords = controller.text);
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

class _TaskStatusFilter {
  final String label;
  final String? status;

  const _TaskStatusFilter(this.label, this.status);
}
