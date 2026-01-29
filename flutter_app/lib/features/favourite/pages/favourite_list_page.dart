import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/models/favourite_model.dart';
import 'package:romance_hub_flutter/core/models/task_model.dart';
import 'package:romance_hub_flutter/core/models/gift_model.dart';
import 'package:romance_hub_flutter/core/models/whisper_model.dart';
import 'package:romance_hub_flutter/core/services/favourite_service.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/empty_widget.dart';

/// 收藏列表页面
class FavouriteListPage extends StatefulWidget {
  final String type; // 'task', 'gift', 'whisper'

  const FavouriteListPage({
    super.key,
    required this.type,
  });

  @override
  State<FavouriteListPage> createState() => _FavouriteListPageState();
}

class _FavouriteListPageState extends State<FavouriteListPage> {
  final FavouriteService _favouriteService = FavouriteService();
  List<FavouriteModel> _favouriteList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FavouriteType type;
      switch (widget.type) {
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

      final response = await _favouriteService.getFavouriteList(type);
      if (response.isSuccess && response.data != null) {
        setState(() {
          _favouriteList = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg)),
          );
        }
      }
    } catch (e) {
      AppLogger.e('加载收藏列表失败', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavourite(FavouriteModel favourite) async {
    try {
      final response = await _favouriteService.removeFavourite(
        collectionId: favourite.collectionId,
        collectionType: favourite.collectionType,
      );

      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('取消收藏成功')),
          );
          _loadFavourites();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg)),
          );
        }
      }
    } catch (e) {
      AppLogger.e('取消收藏失败', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _favouriteList.isEmpty
              ? const EmptyWidget(message: '暂无收藏')
              : RefreshIndicator(
                  onRefresh: _loadFavourites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _favouriteList.length,
                    itemBuilder: (context, index) {
                      final favourite = _favouriteList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(_getItemTitle(favourite)),
                          subtitle: Text(_getItemSubtitle(favourite)),
                          trailing: IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () => _removeFavourite(favourite),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _getTitle() {
    switch (widget.type) {
      case 'task':
        return '任务收藏';
      case 'gift':
        return '礼物收藏';
      case 'whisper':
        return '留言收藏';
      default:
        return '收藏列表';
    }
  }

  String _getItemTitle(FavouriteModel favourite) {
    if (favourite.item == null) return '未知';
    
    switch (favourite.collectionType) {
      case FavouriteType.task:
        return (favourite.item as TaskModel).taskName;
      case FavouriteType.gift:
        return (favourite.item as GiftModel).giftName;
      case FavouriteType.whisper:
        return (favourite.item as WhisperModel).content;
    }
  }

  String _getItemSubtitle(FavouriteModel favourite) {
    if (favourite.item == null) return '';
    
    switch (favourite.collectionType) {
      case FavouriteType.task:
        final task = favourite.item as TaskModel;
        return '积分: ${task.taskScore}';
      case FavouriteType.gift:
        final gift = favourite.item as GiftModel;
        return '积分: ${gift.score}';
      case FavouriteType.whisper:
        final whisper = favourite.item as WhisperModel;
        return '来自: ${whisper.fromUserName}';
    }
  }
}
