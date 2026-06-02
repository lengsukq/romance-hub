import 'package:flutter/material.dart';

enum ListDisplayMode { card, waterfall }

class ListDisplayModeToggle extends StatelessWidget {
  final ListDisplayMode mode;
  final ValueChanged<ListDisplayMode> onChanged;

  const ListDisplayModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final next = mode == ListDisplayMode.card
        ? ListDisplayMode.waterfall
        : ListDisplayMode.card;
    return IconButton(
      icon: Icon(
        mode == ListDisplayMode.card
            ? Icons.dashboard_rounded
            : Icons.view_agenda_rounded,
      ),
      tooltip: mode == ListDisplayMode.card ? '切换到瀑布流' : '切换到卡片列表',
      onPressed: () => onChanged(next),
    );
  }
}
