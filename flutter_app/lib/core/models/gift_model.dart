/// 礼物模型
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
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      giftId: json['giftId'] as int,
      giftName: json['giftName'] as String,
      giftDesc: json['giftDesc'] as String?,
      giftImage: json['giftImage'] as String?,
      score: json['score'] as int,
      publisherId: json['publisherId'] as String,
      publisherName: json['publisherName'] as String,
      isShow: json['isShow'] as bool? ?? true,
      creationTime: json['creationTime'] as String,
      exchangeStatus: json['exchangeStatus'] as String?,
      exchangeTime: json['exchangeTime'] as String?,
      recipientId: json['recipientId'] as String?,
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
    };
  }
}
