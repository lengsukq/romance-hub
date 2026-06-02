import 'package:flutter/material.dart';
import 'package:romance_hub_flutter/core/theme/app_spacing.dart';

class AdaptiveMasonryGrid extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minColumnWidth;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;

  const AdaptiveMasonryGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minColumnWidth = 170,
    this.spacing = AppSpacing.md,
    this.runSpacing = AppSpacing.md,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final columns = (width / minColumnWidth).floor().clamp(1, 4).toInt();
        final columnItems = List.generate(columns, (_) => <int>[]);
        for (var index = 0; index < itemCount; index++) {
          columnItems[index % columns].add(index);
        }

        return Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(columns, (columnIndex) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: columnIndex == 0 ? 0 : spacing / 2,
                    right: columnIndex == columns - 1 ? 0 : spacing / 2,
                  ),
                  child: Column(
                    children: columnItems[columnIndex]
                        .map(
                          (itemIndex) => Padding(
                            padding: EdgeInsets.only(bottom: runSpacing),
                            child: itemBuilder(context, itemIndex),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
