import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/theme/app_radius.dart';
import 'package:romance_hub_flutter/core/theme/app_spacing.dart';

/// 印章式小标签，用于状态、积分、库存等信息。
class SealChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final double? maxWidth;

  const SealChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final base = color ?? colorScheme.primary;
    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.12),
        border: Border.all(color: base.withValues(alpha: 0.45)),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: base),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: base,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (maxWidth == null) return content;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: content,
    );
  }
}
