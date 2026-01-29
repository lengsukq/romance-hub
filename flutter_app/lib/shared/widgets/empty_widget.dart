import 'package:flutter/material.dart';

/// 空数据组件
class EmptyWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;

  const EmptyWidget({
    super.key,
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message ?? '暂无数据',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
