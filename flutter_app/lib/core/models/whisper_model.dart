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
  });

  factory WhisperModel.fromJson(Map<String, dynamic> json) {
    return WhisperModel(
      whisperId: json['whisperId'] as int,
      title: json['title'] as String?,
      content: json['content'] as String,
      fromUserId: json['fromUserId'] as String? ?? json['publisherEmail'] as String? ?? '',
      fromUserName: json['fromUserName'] as String? ?? json['userName'] as String? ?? '',
      toUserId: json['toUserId'] as String? ?? json['toUserEmail'] as String?,
      toUserName: json['toUserName'] as String?,
      userName: json['userName'] as String? ?? json['fromUserName'] as String? ?? '',
      creationTime: json['creationTime'] as String,
      isRead: json['isRead'] as bool? ?? false,
      favId: json['favId'] as int?,
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
    };
  }
}
