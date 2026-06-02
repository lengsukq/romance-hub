import 'package:flutter/widgets.dart';

/// 响应式断点：compact 手机、medium Pad、expanded 大屏/横屏 Pad。
class AppBreakpoints {
  AppBreakpoints._();

  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) => widthOf(context) < compact;

  static bool isMedium(BuildContext context) {
    final width = widthOf(context);
    return width >= compact && width < medium;
  }

  static bool isExpanded(BuildContext context) => widthOf(context) >= medium;

  static bool useNavigationRail(BuildContext context) =>
      widthOf(context) >= compact;

  static double pageHorizontalPadding(BuildContext context) {
    final width = widthOf(context);
    if (width >= expanded) return 40;
    if (width >= compact) return 32;
    return 20;
  }

  static double maxContentWidth(BuildContext context) {
    final width = widthOf(context);
    if (width >= expanded) return 1120;
    if (width >= medium) return 960;
    if (width >= compact) return 760;
    return double.infinity;
  }
}
