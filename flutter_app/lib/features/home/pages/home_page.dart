import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';
import 'package:romance_hub_flutter/core/services/sweet_talk_service.dart';

/// 首页：入口导航 + 情话展示，无切换动画（由 StatefulShellRoute 保证）
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _sweetTalk;
  bool _sweetTalkLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSweetTalk();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('锦书'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '君归矣',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '两心相知，一事一诺',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
          // 情话展示区（每次进入首页拉取一句）
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: _buildSweetTalkCard(context),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _EntryTile(
                  title: '心诺',
                  subtitle: '一览与立诺',
                  icon: Icons.task_alt,
                  color: Colors.blue,
                  onTap: () => context.go(AppRoutes.tasks),
                ),
                _EntryTile(
                  title: '赠礼',
                  subtitle: '赠礼一览',
                  icon: Icons.card_giftcard,
                  color: Colors.pink,
                  onTap: () => context.go(AppRoutes.gifts),
                ),
                _EntryTile(
                  title: '我的赠礼',
                  subtitle: '我的赠礼列表',
                  icon: Icons.inventory_2,
                  color: Colors.deepOrange,
                  onTap: () => context.go(AppRoutes.myGifts),
                ),
                _EntryTile(
                  title: '私语',
                  subtitle: '我的私语 / TA的私语',
                  icon: Icons.chat_bubble,
                  color: Colors.green,
                  onTap: () =>
                      context.go(AppRoutes.whisperList(type: 'my')),
                ),
                _EntryTile(
                  title: '藏心',
                  subtitle: '心诺·赠礼·私语收藏',
                  icon: Icons.favorite,
                  color: Colors.red,
                  onTap: () =>
                      context.go(AppRoutes.favouriteList(type: 'task')),
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _sweetTalk!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _EntryTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 24.0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
