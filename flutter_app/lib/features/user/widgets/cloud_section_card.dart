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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.cloud_rounded, size: 22, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '云阁地址',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onConfig,
                icon: Icon(Icons.settings_rounded, size: 18, color: colorScheme.primary),
                label: const Text('设置'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            baseUrl.isEmpty ? '未配置云阁' : baseUrl,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
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
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
