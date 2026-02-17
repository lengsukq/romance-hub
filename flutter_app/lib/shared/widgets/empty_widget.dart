import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/constants/love_verses.dart';

/// 空数据组件：可选古诗词点缀；未传 verse 时按日展示一句爱情诗词，有惊喜
class EmptyWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;
  /// 可选副句；为 null 时使用当日古诗词（LoveVerses.getVerseOfDay）
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
    final dailyVerse = LoveVerses.getVerseOfDay(DateTime.now());
    final displayVerse = verse ?? dailyVerse.text;
    final showSource = verse == null && dailyVerse.source.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
              textAlign: TextAlign.center,
            ),
            if (displayVerse.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                displayVerse,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                  fontStyle: FontStyle.normal,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              if (showSource) ...[
                const SizedBox(height: 4),
                Text(
                  dailyVerse.source,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
