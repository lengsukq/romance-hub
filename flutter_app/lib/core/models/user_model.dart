/// 用户信息模型
class UserModel {
  final int userId;
  final String userEmail;
  final String username;
  final String? avatar;
  final String? describeBySelf;
  final String lover;
  final int score;
  final String? registrationTime;

  UserModel({
    required this.userId,
    required this.userEmail,
    required this.username,
    this.avatar,
    this.describeBySelf,
    required this.lover,
    required this.score,
    this.registrationTime,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: _int(json, 'userId'),
      userEmail: json['userEmail']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatar: _nullableString(json['avatar']),
      describeBySelf: _nullableString(json['describeBySelf']),
      lover: json['lover']?.toString() ?? '',
      score: _int(json, 'score'),
      registrationTime: _nullableString(json['registrationTime']),
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static int _int(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'username': username,
      'avatar': avatar,
      'describeBySelf': describeBySelf,
      'lover': lover,
      'score': score,
      'registrationTime': registrationTime,
    };
  }

  UserModel copyWith({
    int? userId,
    String? userEmail,
    String? username,
    String? avatar,
    String? describeBySelf,
    String? lover,
    int? score,
    String? registrationTime,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      describeBySelf: describeBySelf ?? this.describeBySelf,
      lover: lover ?? this.lover,
      score: score ?? this.score,
      registrationTime: registrationTime ?? this.registrationTime,
    );
  }
}
