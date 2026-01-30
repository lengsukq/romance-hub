import 'package:flutter/material.dart';

/// 个人信息页区块标题（古风文案，可选诗经副句，符合 UI 准则）
class SectionTitle extends StatelessWidget {
  final String title;
  /// 可选副句，如诗经摘句，显示在标题下方、弱色小字
  final String? verse;

  const SectionTitle({super.key, required this.title, this.verse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          if (verse != null && verse!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              verse!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
