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
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      );
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
