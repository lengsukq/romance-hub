import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/theme/app_radius.dart';
import 'package:romance_hub_flutter/core/theme/app_spacing.dart';

/// 信笺风格通用卡片：暖纸底、柔边框、可选图标印记。
class RomanceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;
  final VoidCallback? onTap;

  const RomanceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.backgroundColor,
    this.borderColor,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: borderColor ?? colorScheme.outline.withValues(alpha: 0.28),
        ),
      ),
      child: icon == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconSeal(icon: icon!),
                const SizedBox(height: AppSpacing.md),
                child,
              ],
            ),
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: card,
      ),
    );
  }
}

class _IconSeal extends StatelessWidget {
  final IconData icon;

  const _IconSeal({required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: colorScheme.primary, size: 22),
    );
  }
}
