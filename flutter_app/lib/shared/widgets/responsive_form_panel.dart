import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/theme/app_breakpoints.dart';
import 'package:romance_hub_flutter/core/theme/app_spacing.dart';
import 'package:romance_hub_flutter/shared/widgets/app_page_container.dart';

/// 表单页响应式外壳：手机单列，Pad 限宽居中。
class ResponsiveFormPanel extends StatelessWidget {
  final Widget child;
  final double compactMaxWidth;
  final double expandedMaxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveFormPanel({
    super.key,
    required this.child,
    this.compactMaxWidth = 520,
    this.expandedMaxWidth = 960,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = AppBreakpoints.isCompact(context)
        ? compactMaxWidth
        : expandedMaxWidth;
    return AppPageContainer(
      maxWidth: maxWidth,
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: AppBreakpoints.pageHorizontalPadding(context),
            vertical: AppSpacing.xl,
          ),
      child: child,
    );
  }
}
