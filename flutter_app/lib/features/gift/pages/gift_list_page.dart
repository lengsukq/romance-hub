import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/models/gift_model.dart';
import 'package:romance_hub_flutter/core/services/gift_service.dart';
import 'package:romance_hub_flutter/core/services/favourite_service.dart';
import 'package:romance_hub_flutter/core/models/favourite_model.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/loading_widget.dart';
import 'package:romance_hub_flutter/shared/widgets/empty_widget.dart';

/// 礼物列表页面
class GiftListPage extends StatefulWidget {
  const GiftListPage({super.key});

  @override
  State<GiftListPage> createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final GiftService _giftService = GiftService();
  final FavouriteService _favouriteService = FavouriteService();
  List<GiftModel> _giftList = [];
  bool _isLoading = false;
  Set<int> _favouriteGiftIds = {};

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
      final response = await _giftService.getGiftList();
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
      AppLogger.e('加载礼物列表失败', e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _exchangeGift(int giftId) async {
    try {
      final response = await _giftService.exchangeGift(giftId);
      if (response.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('兑换成功')),
          );
          _loadGifts();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.msg)),
          );
        }
      }
    } catch (e) {
      AppLogger.e('兑换礼物失败', e);
    }
  }

  Future<void> _toggleFavourite(int giftId) async {
    try {
      if (_favouriteGiftIds.contains(giftId)) {
        final response = await _favouriteService.removeFavourite(
          collectionId: giftId,
          collectionType: FavouriteType.gift,
        );
        if (response.isSuccess) {
          setState(() {
            _favouriteGiftIds.remove(giftId);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已取消收藏')),
            );
          }
        }
      } else {
        final response = await _favouriteService.addFavourite(
          collectionId: giftId,
          collectionType: FavouriteType.gift,
        );
        if (response.isSuccess) {
          setState(() {
            _favouriteGiftIds.add(giftId);
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('赠礼一览'),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => context.go(AppRoutes.myGifts),
            icon: const Icon(Icons.inventory_2_rounded, size: 20),
            label: const Text('我的赠礼'),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.go(AppRoutes.addGift),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _giftList.isEmpty
              ? const EmptyWidget(message: '暂无赠礼')
              : RefreshIndicator(
                  onRefresh: _loadGifts,
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _giftList.length,
                    itemBuilder: (context, index) {
                      final gift = _giftList[index];
                      final theme = Theme.of(context);
                      final colorScheme = theme.colorScheme;
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: gift.giftImage != null
                                  ? Image.network(
                                      gift.giftImage!,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: colorScheme.surfaceContainerHighest,
                                          child: Icon(Icons.image_not_supported_rounded, color: colorScheme.onSurfaceVariant),
                                        );
                                      },
                                    )
                                  : Container(
                                      color: colorScheme.surfaceContainerHighest,
                                      child: Icon(Icons.image_not_supported_rounded, color: colorScheme.onSurfaceVariant),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gift.giftName,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.star_rounded, size: 18, color: colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Text('${gift.score}', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              _favouriteGiftIds.contains(gift.giftId)
                                                  ? Icons.favorite_rounded
                                                  : Icons.favorite_border_rounded,
                                              size: 20,
                                              color: _favouriteGiftIds.contains(gift.giftId)
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurfaceVariant,
                                            ),
                                            onPressed: () => _toggleFavourite(gift.giftId),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 4),
                                          ElevatedButton(
                                            onPressed: () => _exchangeGift(gift.giftId),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            ),
                                            child: const Text('兑换'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
