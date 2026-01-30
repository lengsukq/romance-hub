import 'package:flutter/material.dart';

/// 用户头像：圆形，符合 UI 准则
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;

  const UserAvatar({super.key, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Center(
        child: CircleAvatar(
          radius: 48,
          backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          backgroundImage: NetworkImage(avatarUrl!),
        ),
      ),
    );
  }
}
