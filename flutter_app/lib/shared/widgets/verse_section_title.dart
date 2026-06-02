import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/theme/app_spacing.dart';

/// 带诗词副标题的区块标题，统一"锦书"页面分区风格。
class VerseSectionTitle extends StatelessWidget {
  final String title;
  final String? verse;
  final Widget? trailing;

  const VerseSectionTitle({
    super.key,
    required this.title,
    this.verse,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3,
          height: 38,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              ?_buildVerse(context),
            ],
          ),
        ),
        if (trailing != null)
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: trailing!,
            ),
          ),
      ],
    );
  }

  Widget? _buildVerse(BuildContext context) {
    final v = verse;
    if (v == null || v.isEmpty) return null;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Text(
        v,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
    );
  }
}
