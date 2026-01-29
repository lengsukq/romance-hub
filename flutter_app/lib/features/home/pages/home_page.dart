import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:romance_hub_flutter/core/routes/app_routes.dart';

/// 主页
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RomanceHub'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '欢迎回来',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildFeatureCard(
                    context,
                    '任务',
                    Icons.task,
                    Colors.blue,
                    () => context.go(AppRoutes.tasks),
                  ),
                  _buildFeatureCard(
                    context,
                    '礼物',
                    Icons.card_giftcard,
                    Colors.pink,
                    () => context.go(AppRoutes.gifts),
                  ),
                  _buildFeatureCard(
                    context,
                    '我的礼物',
                    Icons.inventory_2,
                    Colors.deepOrange,
                    () => context.go(AppRoutes.myGifts),
                  ),
                  _buildFeatureCard(
                    context,
                    '留言',
                    Icons.chat,
                    Colors.green,
                    () => context.go(AppRoutes.whisperList(type: 'my')),
                  ),
                  _buildFeatureCard(
                    context,
                    '收藏',
                    Icons.favorite,
                    Colors.red,
                    () => context.go(AppRoutes.favouriteList(type: 'task')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
