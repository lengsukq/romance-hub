/// 图床配置模型（与后端 image_bed_configs 对应）
class ImageBedModel {
  final int id;
  final String bedName;
  final String bedType;
  final String apiUrl;
  final String? apiKey;
  final String? authHeader;
  final bool isActive;
  final bool isDefault;
  final int priority;
  final String? description;
  final String userEmail;

  ImageBedModel({
    required this.id,
    required this.bedName,
    required this.bedType,
    required this.apiUrl,
    this.apiKey,
    this.authHeader,
    required this.isActive,
    required this.isDefault,
    required this.priority,
    this.description,
    required this.userEmail,
  });

  factory ImageBedModel.fromJson(Map<String, dynamic> json) {
    return ImageBedModel(
      id: _int(json, 'id'),
      bedName: json['bedName']?.toString() ?? '',
      bedType: json['bedType']?.toString() ?? '',
      apiUrl: json['apiUrl']?.toString() ?? '',
      apiKey: _nullableString(json['apiKey']),
      authHeader: _nullableString(json['authHeader']),
      isActive: _bool(json['isActive'], true),
      isDefault: _bool(json['isDefault']),
      priority: _int(json, 'priority'),
      description: _nullableString(json['description']),
      userEmail: json['userEmail']?.toString() ?? '',
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

  static int _int(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
