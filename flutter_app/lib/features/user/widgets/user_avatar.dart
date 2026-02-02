import 'package:flutter/material.dart';

/// 用户头像：圆形，符合 UI 准则
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;

  const UserAvatar({super.key, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double radius = 48;

    return Center(
      child: CircleAvatar(
        radius: radius,
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
            ? NetworkImage(avatarUrl!)
            : null,
        child: (avatarUrl == null || avatarUrl!.isEmpty)
            ? Icon(
                Icons.person_rounded,
                size: 48,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              )
            : null,
      ),
    );
  }
}
