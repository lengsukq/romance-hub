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
      bedName: (json['bedName'] as String?) ?? '',
      bedType: (json['bedType'] as String?) ?? '',
      apiUrl: (json['apiUrl'] as String?) ?? '',
      apiKey: json['apiKey'] as String?,
      authHeader: json['authHeader'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isDefault: json['isDefault'] as bool? ?? false,
      priority: _int(json, 'priority'),
      description: json['description'] as String?,
      userEmail: (json['userEmail'] as String?) ?? '',
    );
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
