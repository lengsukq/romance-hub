import 'package:romance_hub_flutter/core/constants/app_constants.dart';

/// API 路径统一管理
/// 所有请求均通过 [ApiService] 发起，路径由此处维护
class ApiEndpoints {
  ApiEndpoints._();

  static const String _base = AppConstants.apiBasePath;

  /// 用户：登录 / 注册 / 登出 / 信息 / 更新 / 积分 / 关联者
  static String get user => '$_base/user';

  /// 任务：列表 / 详情 / 发布 / 更新状态
  static String get task => '$_base/task';

  /// 礼物：列表 / 我的 / 详情 / 创建 / 更新 / 兑换 / 使用 / 上架下架
  static String get gift => '$_base/gift';

  /// 私语：我的列表 / TA 的列表 / 发布
  static String get whisper => '$_base/whisper';

  /// 收藏：添加 / 取消 / 列表
  static String get favourite => '$_base/favourite';

  /// 通用：上传等
  static String get common => '$_base/common';
}
