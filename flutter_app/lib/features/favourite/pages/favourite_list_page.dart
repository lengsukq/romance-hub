import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/models/favourite_model.dart';
import 'package:romance_hub_flutter/core/models/task_model.dart';
import 'package:romance_hub_flutter/core/models/gift_model.dart';
import 'package:romance_hub_flutter/core/models/whisper_model.dart';
import 'package:romance_hub_flutter/core/services/favourite_service.dart';
import 'package:romance_hub_flutter/core/constants/classic_verses.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/empty_widget.dart';

/// 藏心列表页面
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(_getTitle()),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _favouriteList.isEmpty
              ? const EmptyWidget(message: '暂无藏心', verse: ClassicVerses.xiSang)
              : RefreshIndicator(
                  onRefresh: _loadFavourites,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: _favouriteList.length,
                    itemBuilder: (context, index) {
                      final favourite = _favouriteList[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            _getItemTitle(favourite),
                            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                          ),
                          subtitle: Text(
                            _getItemSubtitle(favourite),
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.favorite_rounded, color: colorScheme.primary),
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
        return '心诺藏心';
      case 'gift':
        return '赠礼藏心';
      case 'whisper':
        return '私语藏心';
      default:
        return '藏心一览';
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
        return '来自：${whisper.fromUserName}';
    }
  }
}
