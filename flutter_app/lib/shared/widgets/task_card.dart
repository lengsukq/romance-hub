import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/models/task_model.dart';
import 'package:romance_hub_flutter/shared/widgets/image_viewer.dart';

/// 任务卡片组件
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = 24.0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.taskName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(context, task.taskStatus),
                ],
              ),
              if (task.taskDesc != null && task.taskDesc!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.taskDesc!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (task.taskImage.isNotEmpty) ...[
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: task.taskImage.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ImageViewer(
                                    images: task.taskImage,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              task.taskImage[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
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
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '发布者：${task.publisherName}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${task.taskScore}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = colorScheme.primary;
        label = '待接受';
        break;
      case 'accepted':
        color = colorScheme.primary;
        label = '进行中';
        break;
      case 'completed':
        color = colorScheme.onSurfaceVariant;
        label = '已完成';
        break;
      default:
        color = colorScheme.onSurfaceVariant;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
