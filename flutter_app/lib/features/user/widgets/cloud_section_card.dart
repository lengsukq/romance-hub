import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/constants/classic_verses.dart';

/// 云阁区块卡片：大圆角 24 dp，内容区 padding 20，符合 UI 准则
class CloudSectionCard extends StatelessWidget {
  final String baseUrl;
  final VoidCallback onConfig;

  const CloudSectionCard({
    super.key,
    required this.baseUrl,
    required this.onConfig,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const radius = 24.0;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_rounded, size: 20, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  '云阁地址',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onConfig,
                  icon: Icon(Icons.edit_rounded, size: 18, color: colorScheme.primary),
                  label: const Text('配置'),
                  style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              baseUrl.isEmpty ? '未配置云阁' : baseUrl,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              ClassicVerses.jianJia,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
