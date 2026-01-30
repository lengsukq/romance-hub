/// 应用常量
class AppConstants {
  // API 路径
  static const String apiBasePath = '/api/v1';
  
  // 分页
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;
  
  // 图片
  static const int maxImageCount = 9;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  
  // 任务状态
  static const String taskStatusPending = 'pending';
  static const String taskStatusAccepted = 'accepted';
  static const String taskStatusCompleted = 'completed';
  static const String taskStatusCancelled = 'cancelled';
  
  // 收藏类型
  static const String favouriteTypeTask = 'task';
  static const String favouriteTypeGift = 'gift';
  static const String favouriteTypeWhisper = 'whisper';
}
