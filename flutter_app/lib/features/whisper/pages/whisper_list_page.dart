import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/models/whisper_model.dart';
import 'package:romance_hub_flutter/core/services/whisper_service.dart';
import 'package:romance_hub_flutter/core/services/favourite_service.dart';
import 'package:romance_hub_flutter/core/models/favourite_model.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/empty_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/confirm_dialog.dart';

/// 留言列表页面
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == 'my' ? '我的私语' : 'TA的私语'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go(AppRoutes.postWhisper),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _whisperList.isEmpty
              ? const EmptyWidget(message: '暂无留言')
              : RefreshIndicator(
                  onRefresh: _loadWhispers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _whisperList.length,
                    itemBuilder: (context, index) {
                      final whisper = _whisperList[index];
                      final isFavourite = _favouriteWhisperIds.contains(whisper.whisperId);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            whisper.content,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '来自: ${whisper.fromUserName}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              Text(
                                whisper.creationTime,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isFavourite ? Icons.favorite : Icons.favorite_border,
                                  color: isFavourite ? Colors.red : null,
                                ),
                                onPressed: () => _toggleFavourite(whisper.whisperId),
                              ),
                              if (widget.type == 'my')
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
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
