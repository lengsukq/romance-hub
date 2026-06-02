/// 留言模型
class WhisperModel {
  final int whisperId;
  final String? title;
  final String content;
  final String fromUserId;
  final String fromUserName;
  final String? toUserId;
  final String? toUserName;
  final String userName;
  final String creationTime;
  final bool isRead;
  final int? favId;

  /// TA的私语列表中：true=我发的，false=对方发的，用于区分展示
  final bool? fromMe;

  WhisperModel({
    required this.whisperId,
    this.title,
    required this.content,
    required this.fromUserId,
    required this.fromUserName,
    this.toUserId,
    this.toUserName,
    required this.userName,
    required this.creationTime,
    this.isRead = false,
    this.favId,
    this.fromMe,
  });

  static int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _asBool(dynamic value, [bool fallback = false]) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return fallback;
  }

  static String? _asNullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  factory WhisperModel.fromJson(Map<String, dynamic> json) {
    return WhisperModel(
      whisperId: _asInt(json['whisperId']),
      title: _asNullableString(json['title']),
      content: _asNullableString(json['content']) ?? '',
      fromUserId:
          _asNullableString(json['fromUserId']) ??
          _asNullableString(json['publisherEmail']) ??
          '',
      fromUserName:
          _asNullableString(json['fromUserName']) ??
          _asNullableString(json['publisherName']) ??
          _asNullableString(json['userName']) ??
          '',
      toUserId:
          _asNullableString(json['toUserId']) ??
          _asNullableString(json['toUserEmail']),
      toUserName: _asNullableString(json['toUserName']),
      userName:
          _asNullableString(json['userName']) ??
          _asNullableString(json['fromUserName']) ??
          _asNullableString(json['publisherName']) ??
          '',
      creationTime: json['creationTime']?.toString() ?? '',
      isRead: _asBool(json['isRead']),
      favId: json['favId'] == null ? null : _asInt(json['favId']),
      fromMe: json['fromMe'] == null ? null : _asBool(json['fromMe']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whisperId': whisperId,
      'title': title,
      'content': content,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'userName': userName,
      'creationTime': creationTime,
      'isRead': isRead,
      'favId': favId,
      'fromMe': fromMe,
    };
  }
}
