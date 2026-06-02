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
      notifyType: json['notifyType']?.toString() ?? '',
      notifyName: json['notifyName']?.toString() ?? '',
      webhookUrl: _nullableString(json['webhookUrl']),
      apiKey: _nullableString(json['apiKey']),
      isActive: _bool(json['isActive'], true),
      description: _nullableString(json['description']),
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static bool _bool(dynamic value, [bool fallback = false]) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return fallback;
  }
}
