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
      userId: json['userId'] as int,
      userEmail: json['userEmail'] as String,
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String?,
      describeBySelf: json['describeBySelf'] as String?,
      lover: json['lover'] as String,
      score: json['score'] as int,
      registrationTime: json['registrationTime'] as String?,
    );
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
