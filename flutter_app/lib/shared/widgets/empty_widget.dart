import 'package:flutter/material.dart';

/// 空数据组件（可选诗经等副句点缀）
class EmptyWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;
  /// 可选副句，如诗经摘句，显示在提示下方、弱色小字
  final String? verse;

  const EmptyWidget({
    super.key,
    this.message,
    this.icon,
    this.verse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? '暂无数据',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (verse != null && verse!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              verse!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
