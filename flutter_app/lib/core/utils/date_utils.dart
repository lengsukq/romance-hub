import 'package:intl/intl.dart';

/// 日期工具类
class DateUtils {
  /// 格式化日期时间
  static String formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return '刚刚';
          }
          return '${difference.inMinutes}分钟前';
        }
        return '${difference.inHours}小时前';
      } else if (difference.inDays == 1) {
        return '昨天';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}天前';
      } else {
        return DateFormat('yyyy-MM-dd').format(dateTime);
      }
    } catch (e) {
      return dateTimeString;
    }
  }

  /// 格式化完整日期时间
  static String formatFullDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  /// 格式化日期时间展示（与 Web 一致：yyyy-MM-dd HH:mm）
  static String formatDateTimeDisplay(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return '—';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}
