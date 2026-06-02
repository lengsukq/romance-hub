import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/models/gift_model.dart';
import 'package:romance_hub_flutter/core/services/gift_service.dart';
import 'package:romance_hub_flutter/core/theme/app_spacing.dart';
import 'package:romance_hub_flutter/core/utils/logger.dart';
import 'package:romance_hub_flutter/shared/widgets/adaptive_masonry_grid.dart';
import 'package:romance_hub_flutter/shared/widgets/list_display_mode_toggle.dart';
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
  ListDisplayMode _displayMode = ListDisplayMode.card;

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.msg)));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('使用成功')));
        _loadGifts();
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.msg)));
      }
    } catch (e) {
      AppLogger.e('使用礼物失败', e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('使用失败')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(isShow ? '已上架' : '已下架')));
        _loadGifts();
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.msg)));
      }
    } catch (e) {
      AppLogger.e('上架/下架失败', e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('操作失败')));
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
          ListDisplayModeToggle(
            mode: _displayMode,
            onChanged: (mode) => setState(() => _displayMode = mode),
          ),
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
                  .map(
                    (type) => Padding(
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
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingWidget()
                : _giftList.isEmpty
                ? const EmptyWidget(message: '暂无赠礼')
                : RefreshIndicator(
                    onRefresh: _loadGifts,
                    child: _displayMode == ListDisplayMode.card
                        ? _buildGiftList()
                        : _buildGiftWaterfall(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _giftList.length,
      itemBuilder: (context, index) {
        final gift = _giftList[index];
        final isActionLoading = _actionLoadingGiftId == gift.giftId;
        return _MyGiftTile(
          gift: gift,
          action: _buildActionButton(gift, isActionLoading),
        );
      },
    );
  }

  Widget _buildGiftWaterfall() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: AdaptiveMasonryGrid(
        itemCount: _giftList.length,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemBuilder: (context, index) {
          final gift = _giftList[index];
          final isActionLoading = _actionLoadingGiftId == gift.giftId;
          return _MyGiftWaterfallCard(
            gift: gift,
            action: _buildActionButton(gift, isActionLoading),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(GiftModel gift, bool isActionLoading) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isActionLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colorScheme.primary,
        ),
      );
    }
    if (_currentType == '待使用') {
      return ElevatedButton(
        onPressed: (gift.remained ?? 0) > 0 ? () => _useGift(gift) : null,
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

class _MyGiftTile extends StatelessWidget {
  final GiftModel gift;
  final Widget action;

  const _MyGiftTile({required this.gift, required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        leading: _GiftThumb(imageUrl: gift.giftImage, size: 56),
        title: Text(
          gift.giftName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: _GiftMeta(gift: gift),
        trailing: action,
      ),
    );
  }
}

class _MyGiftWaterfallCard extends StatelessWidget {
  final GiftModel gift;
  final Widget action;

  const _MyGiftWaterfallCard({required this.gift, required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GiftThumb(
            imageUrl: gift.giftImage,
            size: double.infinity,
            height: 118,
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.giftName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _GiftMeta(gift: gift),
                const SizedBox(height: AppSpacing.sm),
                action,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GiftMeta extends StatelessWidget {
  final GiftModel gift;

  const _GiftMeta({required this.gift});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star_rounded, size: 14, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              '${gift.score} 积分',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (gift.remained != null)
          Text(
            '剩余 ${gift.remained}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

class _GiftThumb extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final double? height;

  const _GiftThumb({required this.imageUrl, required this.size, this.height});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final child = hasImage
        ? Image.network(
            imageUrl!,
            width: size,
            height: height ?? size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _placeholder(context, isError: true),
          )
        : _placeholder(context, isError: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(width: size, height: height ?? size, child: child),
    );
  }

  Widget _placeholder(BuildContext context, {required bool isError}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: isError
          ? colorScheme.surfaceContainerHighest
          : colorScheme.primaryContainer.withValues(alpha: 0.28),
      child: Center(
        child: Icon(
          isError
              ? Icons.image_not_supported_rounded
              : Icons.card_giftcard_rounded,
          color: isError ? colorScheme.onSurfaceVariant : colorScheme.primary,
        ),
      ),
    );
  }
}
