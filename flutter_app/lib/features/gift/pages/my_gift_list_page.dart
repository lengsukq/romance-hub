import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/models/gift_model.dart';
import 'package:romance_hub_flutter/core/services/gift_service.dart';
import 'package:romance_hub_flutter/core/constants/classic_verses.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/empty_widget.dart';

/// 我的礼物类型（与 Web 后端一致）
const List<String> _myGiftTypes = ['已上架', '已下架', '待使用', '已用完'];

/// 我的礼物页面（货架）
/// 支持按类型筛选：已上架、已下架、待使用、已用完；使用礼物、上架/下架
class MyGiftListPage extends StatefulWidget {
  const MyGiftListPage({super.key});

  @override
  State<MyGiftListPage> createState() => _MyGiftListPageState();
}

class _MyGiftListPageState extends State<MyGiftListPage> {
  final GiftService _giftService = GiftService();
  List<GiftModel> _giftList = [];
  bool _isLoading = false;
  String _currentType = '已上架';
  int _actionLoadingGiftId = -1;

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _giftService.getMyGiftList(
        type: _currentType,
        searchWords: null,
      );
      if (response.isSuccess && response.data != null) {
        setState(() {
          _giftList = response.data!;
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
      AppLogger.e('加载我的礼物失败', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _useGift(GiftModel gift) async {
    setState(() {
      _actionLoadingGiftId = gift.giftId;
    });
    try {
      final response = await _giftService.useGift(gift.giftId);
      if (response.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('使用成功')),
        );
        _loadGifts();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.msg)),
        );
      }
    } catch (e) {
      AppLogger.e('使用礼物失败', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('使用失败')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingGiftId = -1;
        });
      }
    }
  }

  Future<void> _toggleShow(GiftModel gift, bool isShow) async {
    setState(() {
      _actionLoadingGiftId = gift.giftId;
    });
    try {
      final response = await _giftService.toggleGiftShow(
        giftId: gift.giftId,
        isShow: isShow,
      );
      if (response.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isShow ? '已上架' : '已下架')),
        );
        _loadGifts();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.msg)),
        );
      }
    } catch (e) {
      AppLogger.e('上架/下架失败', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('操作失败')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _actionLoadingGiftId = -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('我的赠礼'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go(AppRoutes.addGift),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: _myGiftTypes
                  .map((type) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(type),
                          selected: _currentType == type,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _currentType = type;
                              });
                              _loadGifts();
                            }
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _giftList.isEmpty
                    ? const EmptyWidget(message: '暂无赠礼', verse: ClassicVerses.muGua)
                    : RefreshIndicator(
                        onRefresh: _loadGifts,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          itemCount: _giftList.length,
                          itemBuilder: (context, index) {
                            final gift = _giftList[index];
                            final isActionLoading =
                                _actionLoadingGiftId == gift.giftId;
                            final theme = Theme.of(context);
                            final colorScheme = theme.colorScheme;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                leading: gift.giftImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          gift.giftImage!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              width: 56,
                                              height: 56,
                                              color: colorScheme.surfaceContainerHighest,
                                              child: Icon(Icons.image_not_supported_rounded, color: colorScheme.onSurfaceVariant),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Icon(Icons.image_not_supported_rounded, color: colorScheme.onSurfaceVariant),
                                      ),
                                title: Text(
                                  gift.giftName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.star_rounded, size: 14, color: colorScheme.primary),
                                        const SizedBox(width: 4),
                                        Text('${gift.score} 积分',
                                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                                        if (gift.remained != null) ...[
                                          const SizedBox(width: 12),
                                          Text(
                                            '剩余 ${gift.remained}',
                                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: _buildActionButton(
                                    gift, isActionLoading),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(GiftModel gift, bool isActionLoading) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isActionLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
      );
    }
    if (_currentType == '待使用') {
      return ElevatedButton(
        onPressed: (gift.remained ?? 0) > 0
            ? () => _useGift(gift)
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: const Text('使用'),
      );
    }
    if (_currentType == '已上架') {
      return TextButton(
        onPressed: () => _toggleShow(gift, false),
        child: const Text('下架'),
      );
    }
    if (_currentType == '已下架') {
      return TextButton(
        onPressed: () => _toggleShow(gift, true),
        child: const Text('上架'),
      );
    }
    return const SizedBox.shrink();
  }
}
