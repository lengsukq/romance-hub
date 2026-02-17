import 'package:flutter/material.dart';

/// 2026 年马年专属标识（与 Web 端 home-2026__badge / login-2026__badge 一致）
class Year2026Badge extends StatelessWidget {
  /// 主文案，如 "2026" 或 "锦书"
  final String label;

  /// 是否使用较大样式（登录页用 true，首页/列表头用 false）
  final bool large;

  const Year2026Badge({
    super.key,
    this.label = '2026',
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 12,
        vertical: large ? 6 : 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(large ? 12 : 10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.85),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: large ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: large ? 0.2 : 0.15,
          color: colorScheme.onPrimary,
        ) ?? TextStyle(
          fontSize: large ? 16 : 14,
          fontWeight: FontWeight.w700,
          letterSpacing: large ? 0.2 : 0.15,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
