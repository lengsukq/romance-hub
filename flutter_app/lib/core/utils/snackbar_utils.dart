import 'package:flutter/material.dart';

/// SnackBar 工具类（使用主题色，符合 UI 设计规则）
class SnackBarUtils {
  /// 显示成功消息
  static void showSuccess(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: colorScheme.onPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示错误消息
  static void showError(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_rounded, color: colorScheme.onError),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onError),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示警告消息
  static void showWarning(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_rounded, color: colorScheme.onSurface),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 显示信息消息
  static void showInfo(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: colorScheme.onPrimary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onPrimary),
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
