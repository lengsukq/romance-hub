import 'package:romance_hub_flutter/core/models/task_model.dart';
import 'package:romance_hub_flutter/core/models/gift_model.dart';
import 'package:romance_hub_flutter/core/models/whisper_model.dart';

/// 收藏类型
enum FavouriteType { task, gift, whisper }

/// 收藏模型
class FavouriteModel {
  final int favouriteId;
  final int collectionId;
  final FavouriteType collectionType;
  final String userId;
  final String creationTime;
  final dynamic item; // TaskModel | GiftModel | WhisperModel

  FavouriteModel({
    required this.favouriteId,
    required this.collectionId,
    required this.collectionType,
    required this.userId,
    required this.creationTime,
    this.item,
  });

  static int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['collectionType']?.toString() ?? '';
    FavouriteType type;
    switch (typeStr) {
      case 'task':
        type = FavouriteType.task;
        break;
      case 'gift':
        type = FavouriteType.gift;
        break;
      case 'whisper':
        type = FavouriteType.whisper;
        break;
      default:
        type = FavouriteType.task;
    }

    final favouriteId = _asInt(json['favouriteId'] ?? json['favId']);
    final collectionId = _asInt(json['collectionId']);
    final userId =
        json['userId']?.toString() ?? json['userEmail']?.toString() ?? '';
    final creationTime =
        json['creationTime'] as String? ?? json['favTime']?.toString() ?? '';

    dynamic itemData;
    final itemJson = json['item'];
    final itemSource = itemJson is Map
        ? Map<String, dynamic>.from(itemJson)
        : Map<String, dynamic>.from(json);
    if (itemSource.isNotEmpty) {
      try {
        switch (type) {
          case FavouriteType.task:
            itemData = TaskModel.fromJson(itemSource);
            break;
          case FavouriteType.gift:
            itemData = GiftModel.fromJson(itemSource);
            break;
          case FavouriteType.whisper:
            itemData = WhisperModel.fromJson(itemSource);
            break;
        }
      } catch (_) {
        itemData = null;
      }
    }

    return FavouriteModel(
      favouriteId: favouriteId,
      collectionId: collectionId,
      collectionType: type,
      userId: userId,
      creationTime: creationTime,
      item: itemData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favouriteId': favouriteId,
      'collectionId': collectionId,
      'collectionType': collectionType.name,
      'userId': userId,
      'creationTime': creationTime,
      'item': item,
    };
  }
}
