/// 礼物模型
/// 兼容后端字段：giftDetail/giftDesc, giftImg/giftImage, needScore/score, publisherEmail/publisherId
class GiftModel {
  final int giftId;
  final String giftName;
  final String? giftDesc;
  final String? giftImage;
  final int score;
  final String publisherId;
  final String publisherName;
  final bool isShow;
  final String creationTime;
  final String? exchangeStatus;
  final String? exchangeTime;
  final String? recipientId;
  /// 剩余数量（我的礼物列表用）
  final int? remained;

  GiftModel({
    required this.giftId,
    required this.giftName,
    this.giftDesc,
    this.giftImage,
    required this.score,
    required this.publisherId,
    required this.publisherName,
    required this.isShow,
    required this.creationTime,
    this.exchangeStatus,
    this.exchangeTime,
    this.recipientId,
    this.remained,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    final creationTime = json['creationTime'];
    final creationTimeStr = creationTime == null
        ? ''
        : (creationTime is String ? creationTime : creationTime.toString());
    final publisher = json['publisher'];
    final publisherName = publisher is Map<String, dynamic>
        ? (publisher['username'] as String? ?? '')
        : (json['publisherName'] as String? ?? '');
    return GiftModel(
      giftId: json['giftId'] as int,
      giftName: json['giftName'] as String,
      giftDesc: json['giftDesc'] as String? ?? json['giftDetail'] as String?,
      giftImage: json['giftImage'] as String? ?? json['giftImg'] as String?,
      score: (json['score'] ?? json['needScore']) as int,
      publisherId: (json['publisherId'] ?? json['publisherEmail']) as String,
      publisherName: publisherName,
      isShow: json['isShow'] as bool? ?? true,
      creationTime: creationTimeStr,
      exchangeStatus: json['exchangeStatus'] as String?,
      exchangeTime: json['exchangeTime'] as String?,
      recipientId: json['recipientId'] as String?,
      remained: json['remained'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'giftId': giftId,
      'giftName': giftName,
      'giftDesc': giftDesc,
      'giftImage': giftImage,
      'score': score,
      'publisherId': publisherId,
      'publisherName': publisherName,
      'isShow': isShow,
      'creationTime': creationTime,
      'exchangeStatus': exchangeStatus,
      'exchangeTime': exchangeTime,
      'recipientId': recipientId,
      'remained': remained,
    };
  }
}
