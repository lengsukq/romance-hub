import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/theme/app_breakpoints.dart';

/// 页面内容响应式容器：手机保留舒适边距，Pad 居中并限制最大宽度。
class AppPageContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const AppPageContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final horizontal = AppBreakpoints.pageHorizontalPadding(context);
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppBreakpoints.maxContentWidth(context),
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
          child: child,
        ),
      ),
    );
  }
}
