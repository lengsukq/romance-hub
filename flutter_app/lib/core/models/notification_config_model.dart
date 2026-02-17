/// 通知配置模型（与后端 notification_configs 对应）
class NotificationConfigModel {
  final String id;
  final String notifyType;
  final String notifyName;
  final String? webhookUrl;
  final String? apiKey;
  final bool isActive;
  final String? description;

  NotificationConfigModel({
    required this.id,
    required this.notifyType,
    required this.notifyName,
    this.webhookUrl,
    this.apiKey,
    this.isActive = true,
    this.description,
  });

  factory NotificationConfigModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    return NotificationConfigModel(
      id: id?.toString() ?? '',
      notifyType: (json['notifyType'] as String?) ?? '',
      notifyName: (json['notifyName'] as String?) ?? '',
      webhookUrl: json['webhookUrl'] as String?,
      apiKey: json['apiKey'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      description: json['description'] as String?,
    );
  }
}
