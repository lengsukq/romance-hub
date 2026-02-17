import 'package:romance_hub_flutter/core/models/task_model.dart';
import 'package:romance_hub_flutter/core/models/gift_model.dart';
import 'package:romance_hub_flutter/core/models/whisper_model.dart';

/// 收藏类型
enum FavouriteType {
  task,
  gift,
  whisper,
}

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

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['collectionType'] as String? ?? '';
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

    final favouriteId = json['favouriteId'] as int? ?? json['favId'] as int? ?? 0;
    final collectionIdRaw = json['collectionId'];
    final collectionId = collectionIdRaw is int
        ? collectionIdRaw
        : (int.tryParse(collectionIdRaw?.toString() ?? '') ?? 0);
    final userId = json['userId'] as String? ?? '';
    final creationTime = json['creationTime'] as String? ?? json['favTime']?.toString() ?? '';

    dynamic itemData;
    final itemJson = json['item'];
    if (itemJson is Map<String, dynamic>) {
      try {
        switch (type) {
          case FavouriteType.task:
            itemData = TaskModel.fromJson(itemJson);
            break;
          case FavouriteType.gift:
            itemData = GiftModel.fromJson(itemJson);
            break;
          case FavouriteType.whisper:
            itemData = WhisperModel.fromJson(itemJson);
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
