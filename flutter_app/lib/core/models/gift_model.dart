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

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    final creationTime = json['creationTime'];
    final creationTimeStr = creationTime == null
        ? ''
        : (creationTime is String ? creationTime : creationTime.toString());
    final publisher = json['publisher'];
    final publisherName = publisher is Map<String, dynamic>
        ? (_asNullableString(publisher['username']) ?? '')
        : (_asNullableString(json['publisherName']) ?? '');
    return GiftModel(
      giftId: _asInt(json['giftId']),
      giftName: _asNullableString(json['giftName']) ?? '',
      giftDesc:
          _asNullableString(json['giftDesc']) ??
          _asNullableString(json['giftDetail']),
      giftImage:
          _asNullableString(json['giftImage']) ??
          _asNullableString(json['giftImg']),
      score: _asInt(json['score'] ?? json['needScore']),
      publisherId:
          _asNullableString(json['publisherId']) ??
          _asNullableString(json['publisherEmail']) ??
          '',
      publisherName: publisherName,
      isShow: _asBool(json['isShow'], true),
      creationTime: creationTimeStr,
      exchangeStatus: _asNullableString(json['exchangeStatus']),
      exchangeTime: _asNullableString(json['exchangeTime']),
      recipientId:
          _asNullableString(json['recipientId']) ??
          _asNullableString(json['receiverEmail']),
      remained: json.containsKey('remained') ? _asInt(json['remained']) : null,
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
