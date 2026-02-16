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

  factory WhisperModel.fromJson(Map<String, dynamic> json) {
    return WhisperModel(
      whisperId: json['whisperId'] as int,
      title: json['title'] as String?,
      content: json['content'] as String,
      fromUserId: json['fromUserId'] as String? ?? json['publisherEmail'] as String? ?? '',
      fromUserName: json['fromUserName'] as String? ?? json['publisherName'] as String? ?? json['userName'] as String? ?? '',
      toUserId: json['toUserId'] as String? ?? json['toUserEmail'] as String?,
      toUserName: json['toUserName'] as String?,
      userName: json['userName'] as String? ?? json['fromUserName'] as String? ?? json['publisherName'] as String? ?? '',
      creationTime: json['creationTime'] as String,
      isRead: json['isRead'] as bool? ?? false,
      favId: json['favId'] as int?,
      fromMe: json['fromMe'] as bool?,
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
