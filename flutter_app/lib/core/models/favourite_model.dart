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
    final typeStr = json['collectionType'] as String;
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

    dynamic itemData;
    if (json['item'] != null) {
      switch (type) {
        case FavouriteType.task:
          itemData = TaskModel.fromJson(json['item'] as Map<String, dynamic>);
          break;
        case FavouriteType.gift:
          itemData = GiftModel.fromJson(json['item'] as Map<String, dynamic>);
          break;
        case FavouriteType.whisper:
          itemData = WhisperModel.fromJson(json['item'] as Map<String, dynamic>);
          break;
      }
    }

    return FavouriteModel(
      favouriteId: json['favouriteId'] as int,
      collectionId: json['collectionId'] as int,
      collectionType: type,
      userId: json['userId'] as String,
      creationTime: json['creationTime'] as String,
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
