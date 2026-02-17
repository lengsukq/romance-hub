import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/config/app_config.dart';
import 'package:romance_hub_flutter/core/constants/love_verses.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/services/config_service.dart';
import 'package:romance_hub_flutter/core/services/sweet_talk_service.dart';
import 'package:romance_hub_flutter/core/utils/snackbar_utils.dart';
import 'package:romance_hub_flutter/shared/widgets/year_2026_badge.dart';

/// 首页：按日变化的问候与古诗词，每次进入皆有惊喜入口导航 + 情话展示，无切换动画（由 StatefulShellRoute 保证）
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
      if (_coupleSince != null && _coupleSince!.trim().isEmpty) _coupleSince = null;
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
      body: CustomScrollView(
        slivers: [
          // 2026 马年专属 + 按日变化的诗意欢迎区
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Year2026Badge(label: '2026', large: false),
                  const SizedBox(height: 10),
                  Text(
                    LoveVerses.getGreetingOfDay(DateTime.now()),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
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
          // 与君相守 · 实时计时 或 未设置时跳转配置
          if (_coupleConfigFetched)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _coupleSince != null
                    ? _buildCoupleCounterCard(context)
                    : _buildCoupleSetHintCard(context),
              ),
            ),
          // 今日一句：古诗词（按日一变，有惊喜）
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: _buildVerseOfDayCard(context),
            ),
          ),
          // 今日一言：情话卡片
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _buildSweetTalkCard(context),
            ),
          ),
          // 入口区标题（按日切换文案）
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                LoveVerses.getSectionTitleOfDay(DateTime.now()),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          // 入口网格：上排 2 个，下排 2 个，最后 1 个占满
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    Expanded(
                      child: _EntryCard(
                        title: '心诺',
                        subtitle: '一览与立诺',
                        icon: Icons.task_alt_rounded,
                        onTap: () => context.go(AppRoutes.tasks),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _EntryCard(
                        title: '赠礼',
                        subtitle: '赠礼一览',
                        icon: Icons.card_giftcard_rounded,
                        onTap: () => context.go(AppRoutes.gifts),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _EntryCard(
                        title: '私语',
                        subtitle: '我的 / TA的',
                        icon: Icons.chat_bubble_rounded,
                        onTap: () => context.go(AppRoutes.whisperList(type: 'my')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _EntryCard(
                        title: '藏心',
                        subtitle: '心诺·赠礼·私语',
                        icon: Icons.favorite_rounded,
                        onTap: () => context.go(AppRoutes.favouriteList(type: 'task')),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _EntryTile(
                  title: '我的赠礼',
                  subtitle: '我的赠礼列表',
                  icon: Icons.inventory_2_rounded,
                  onTap: () => context.go(AppRoutes.myGifts),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildCoupleSetHintCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = 20.0;
    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: () => context.go(AppRoutes.config),
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '相守至今',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '轻触设置相守之日',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '在设置中填写「在一起的日子」后，此处将显示相守时长',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
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
    const radius = 20.0;
    return Material(
      color: colorScheme.primaryContainer.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: _toggleCounterMode,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '相守至今',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '轻触切换 天时秒 / 仅秒',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 今日一句：古诗词卡片，按日一变
  Widget _buildVerseOfDayCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = 20.0;
    final verse = LoveVerses.getVerseOfDay(DateTime.now());

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            margin: const EdgeInsets.only(top: 2),
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '今日一句',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  verse.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                    letterSpacing: 0.3,
                  ),
                ),
                if (verse.source.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    verse.source,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSweetTalkCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = 24.0;

    if (_sweetTalkLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.25),
          ),
        ),
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
            const SizedBox(width: 10),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '今日一言',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _sweetTalk!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _copySweetTalk(context),
                icon: Icon(Icons.copy_rounded, size: 18, color: colorScheme.primary),
                label: Text('复制', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _refreshSweetTalk,
                icon: Icon(Icons.refresh_rounded, size: 18, color: colorScheme.primary),
                label: Text('更新', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 入口小卡片：用于 2 列网格，主色统一
class _EntryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _EntryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = 20.0;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 入口长条：单行占满，主色统一
class _EntryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _EntryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = 24.0;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
