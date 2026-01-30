import 'package:flutter/material.dart';

/// 刷新包装组件
/// 统一处理下拉刷新和错误重试
class RefreshWrapper extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const RefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      );
    }

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: colorScheme.primary),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
