import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/models/whisper_model.dart';
import 'package:romance_hub_flutter/core/services/whisper_service.dart';
import 'package:romance_hub_flutter/core/services/favourite_service.dart';
import 'package:romance_hub_flutter/core/models/favourite_model.dart';
import 'package:romance_hub_flutter/core/utils/date_utils.dart' as app_date_utils;
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/empty_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/confirm_dialog.dart';

/// 私语列表页面
class WhisperListPage extends StatefulWidget {
  final String type; // 'my' or 'ta'

  const WhisperListPage({
    super.key,
    required this.type,
  });

  @override
  State<WhisperListPage> createState() => _WhisperListPageState();
}

class _WhisperListPageState extends State<WhisperListPage> {
  final WhisperService _whisperService = WhisperService();
  final FavouriteService _favouriteService = FavouriteService();
  List<WhisperModel> _whisperList = [];
  bool _isLoading = false;
  Set<int> _favouriteWhisperIds = {};

  @override
  void initState() {
    super.initState();
    _loadWhispers();
  }

  Future<void> _loadWhispers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = widget.type == 'my'
          ? await _whisperService.getMyWhisperList()
          : await _whisperService.getTAWhisperList();
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _whisperList = response.data!;
          _favouriteWhisperIds = response.data!
              .where((w) => w.favId != null)
              .map((w) => w.whisperId)
              .toSet();
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
      AppLogger.e('加载留言列表失败', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteWhisper(WhisperModel whisper) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: '确认删除',
      message: '确定要删除此私语吗？',
      confirmText: '删除',
      cancelText: '取消',
    );
    if (confirmed != true || !mounted) return;

    try {
      final response = await _whisperService.deleteWhisper(whisper.whisperId);
      if (response.isSuccess && mounted) {
        setState(() {
          _whisperList.removeWhere((w) => w.whisperId == whisper.whisperId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已删除')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.msg)),
        );
      }
    } catch (e) {
      AppLogger.e('删除留言失败', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除失败')),
        );
      }
    }
  }

  Future<void> _toggleFavourite(int whisperId) async {
    try {
      if (_favouriteWhisperIds.contains(whisperId)) {
        final response = await _favouriteService.removeFavourite(
          collectionId: whisperId,
          collectionType: FavouriteType.whisper,
        );
        if (response.isSuccess) {
          setState(() {
            _favouriteWhisperIds.remove(whisperId);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已取消收藏')),
            );
          }
        }
      } else {
        final response = await _favouriteService.addFavourite(
          collectionId: whisperId,
          collectionType: FavouriteType.whisper,
        );
        if (response.isSuccess) {
          setState(() {
            _favouriteWhisperIds.add(whisperId);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已添加收藏')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.msg)),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.e('收藏操作失败', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.type == 'my' ? '我的私语' : 'TA的私语'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go(AppRoutes.postWhisper),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _whisperList.isEmpty
              ? const EmptyWidget(message: '暂无私语')
              : RefreshIndicator(
                  onRefresh: _loadWhispers,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: _whisperList.length,
                    itemBuilder: (context, index) {
                      final whisper = _whisperList[index];
                      final isFavourite = _favouriteWhisperIds.contains(whisper.whisperId);
                      final isTAList = widget.type == 'ta';
                      final fromMe = whisper.fromMe ?? false;
                      final showAsMine = isTAList && fromMe;
                      final showDelete = widget.type == 'my' || showAsMine;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        color: isTAList
                            ? (showAsMine ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest)
                            : null,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            whisper.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isTAList && showAsMine ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                isTAList
                                    ? (showAsMine ? '我' : 'TA')
                                    : '来自：${whisper.fromUserName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isTAList && showAsMine
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: isTAList ? FontWeight.w600 : null,
                                ),
                              ),
                              Text(
                                app_date_utils.DateUtils.formatDateTimeDisplay(whisper.creationTime),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isTAList && showAsMine
                                      ? colorScheme.onPrimaryContainer.withValues(alpha: 0.8)
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isFavourite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFavourite ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                ),
                                onPressed: () => _toggleFavourite(whisper.whisperId),
                              ),
                              if (showDelete)
                                IconButton(
                                  icon: Icon(Icons.delete_outline_rounded, color: colorScheme.onSurfaceVariant),
                                  onPressed: () => _deleteWhisper(whisper),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
