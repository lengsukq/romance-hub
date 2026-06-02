import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/constants/love_verses.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/services/config_service.dart';
import 'package:romance_hub_flutter/core/services/sweet_talk_service.dart';

import 'package:romance_hub_flutter/core/theme/app_spacing.dart';
import 'package:romance_hub_flutter/core/utils/snackbar_utils.dart';
import 'package:romance_hub_flutter/shared/widgets/adaptive_grid.dart';
import 'package:romance_hub_flutter/shared/widgets/app_page_container.dart';
import 'package:romance_hub_flutter/shared/widgets/romance_card.dart';
import 'package:romance_hub_flutter/shared/widgets/seal_chip.dart';
import 'package:romance_hub_flutter/shared/widgets/verse_section_title.dart';
import 'package:romance_hub_flutter/shared/widgets/year_2026_badge.dart';

/// 首页：按日变化的问候与古诗词，每次进入皆有惊喜入口导航 + 情话展示
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ConfigService _configService = ConfigService();
  String? _sweetTalk;
  bool _sweetTalkLoading = true;
  String? _coupleSince;
  bool _coupleConfigFetched = false;
  String _counterMode = 'full';
  Timer? _coupleTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSweetTalk();
    _loadCoupleSinceAndMode();
  }

  @override
  void dispose() {
    _coupleTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCoupleSinceAndMode() async {
    final res = await _configService.getSystemConfigs();
    final mode = await AppConfig.getCoupleCounterDisplayMode();
    if (!mounted) return;
    setState(() {
      _coupleConfigFetched = true;
      _coupleSince = res.data?['COUPLE_SINCE'];
      if (_coupleSince != null && _coupleSince!.trim().isEmpty) {
        _coupleSince = null;
      }
      _counterMode = mode;
    });
    if (_coupleSince != null) {
      _coupleTimer?.cancel();
      _coupleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _now = DateTime.now());
      });
    }
  }

  void _toggleCounterMode() {
    final next = _counterMode == 'full' ? 'seconds' : 'full';
    AppConfig.setCoupleCounterDisplayMode(next);
    setState(() => _counterMode = next);
  }

  Future<void> _loadSweetTalk() async {
    final text = await SweetTalkService.instance.fetchOne();
    if (mounted) {
      setState(() {
        _sweetTalk = text;
        _sweetTalkLoading = false;
      });
    }
  }

  void _copySweetTalk(BuildContext context) {
    if (_sweetTalk == null || _sweetTalk!.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _sweetTalk!));
    SnackBarUtils.showSuccess(context, '已复制到剪贴板');
  }

  void _refreshSweetTalk() {
    setState(() => _sweetTalkLoading = true);
    _loadSweetTalk();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('锦书'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: AppPageContainer(
        child: CustomScrollView(
          slivers: [
            // 诗意欢迎区
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  bottom: AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Year2026Badge(label: '2026', large: false),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      LoveVerses.getGreetingOfDay(DateTime.now()),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      LoveVerses.getShortVerseOfDay(DateTime.now()).text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.4,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 相守计时
            if (_coupleConfigFetched)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _coupleSince != null
                      ? _buildCoupleCounterCard(context)
                      : _buildCoupleSetHintCard(context),
                ),
              ),
            // 今日一言
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: _buildSweetTalkCard(context),
              ),
            ),
            // 入口区
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: VerseSectionTitle(
                  title: LoveVerses.getSectionTitleOfDay(DateTime.now()),
                  verse: '轻触即达，心诺即赴',
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildEntryGrid(context)),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryGrid(BuildContext context) {
    final entries = [
      _EntryData(
        '心诺',
        '一览与立诺',
        Icons.task_alt_rounded,
        () => context.go(AppRoutes.tasks),
      ),
      _EntryData(
        '赠礼',
        '赠礼一览',
        Icons.card_giftcard_rounded,
        () => context.go(AppRoutes.gifts),
      ),
      _EntryData(
        '私语',
        '我的 / TA的',
        Icons.chat_bubble_rounded,
        () => context.go(AppRoutes.whisperList(type: 'my')),
      ),
      _EntryData(
        '藏心',
        '心诺·赠礼·私语',
        Icons.favorite_rounded,
        () => context.go(AppRoutes.favouriteList(type: 'task')),
      ),
      _EntryData(
        '我的赠礼',
        '我的赠礼列表',
        Icons.inventory_2_rounded,
        () => context.go(AppRoutes.myGifts),
      ),
    ];

    return AdaptiveGrid(
      itemCount: entries.length,
      minItemWidth: 160,
      childAspectRatio: 1.05,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return RomanceCard(
          icon: entry.icon,
          onTap: entry.onTap,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                entry.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoupleSetHintCard(BuildContext context) {
    return RomanceCard(
      icon: Icons.favorite_outline_rounded,
      onTap: () => context.go(AppRoutes.config),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SealChip(label: '相守至今', icon: Icons.hourglass_empty_rounded),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '轻触设置相守之日',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '在设置中填写「在一起的日子」后，此处将显示相守时长',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoupleCounterCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final start = DateTime.tryParse('$_coupleSince 00:00:00');
    if (start == null || _now.isBefore(start)) return const SizedBox.shrink();
    final diff = _now.difference(start);
    final totalSeconds = diff.inSeconds;
    final days = totalSeconds ~/ 86400;
    final rest = totalSeconds % 86400;
    final hours = rest ~/ 3600;
    final rest2 = rest % 3600;
    final seconds = rest2 % 60;
    final label = _counterMode == 'full'
        ? '与君相守 已 $days 天 $hours 时 $seconds 秒'
        : '共度 $totalSeconds 秒';

    return RomanceCard(
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.25),
      onTap: _toggleCounterMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SealChip(
            label: '相守至今',
            icon: Icons.favorite_rounded,
            color: colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '轻触切换 天时秒 / 仅秒',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSweetTalkCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_sweetTalkLoading) {
      return RomanceCard(
        backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '一言一语…',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_sweetTalk == null || _sweetTalk!.isEmpty) {
      return const SizedBox.shrink();
    }

    return RomanceCard(
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerseSectionTitle(
            title: '今日一言',
            trailing: IconButton(
              icon: Icon(
                Icons.copy_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              onPressed: () => _copySweetTalk(context),
              tooltip: '复制',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _sweetTalk!,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _refreshSweetTalk,
              icon: Icon(
                Icons.refresh_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              label: Text(
                '换一句',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryData {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _EntryData(this.title, this.subtitle, this.icon, this.onTap);
}
