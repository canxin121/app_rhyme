import 'package:flutter/rendering.dart';

class SliverGridDelegateWithResponsiveColumnCount extends SliverGridDelegate {
  final double minColumnWidth;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final int minColumnCount;
  final int maxColumnCount;

  const SliverGridDelegateWithResponsiveColumnCount({
    required this.minColumnWidth,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.minColumnCount,
    required this.maxColumnCount,
  });

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final double availableWidth = constraints.crossAxisExtent;
    final int columnCount = (availableWidth / minColumnWidth)
        .clamp(minColumnCount, maxColumnCount)
        .toInt();
    final double columnWidth =
        (availableWidth - (columnCount - 1) * crossAxisSpacing) / columnCount;

    double childHeight = _calculateChildHeight(columnWidth);

    return SliverGridRegularTileLayout(
      crossAxisCount: columnCount,
      mainAxisStride: childHeight + mainAxisSpacing,
      crossAxisStride: columnWidth + crossAxisSpacing,
      childMainAxisExtent: childHeight,
      childCrossAxisExtent: columnWidth,
      reverseCrossAxis: false,
    );
  }

  double _calculateChildHeight(double columnWidth) {
    double imageHeight = columnWidth;
    double textHeight = 50.0;
    double descHeight = 30.0;
    return imageHeight + textHeight + descHeight;
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithResponsiveColumnCount oldDelegate) {
    return oldDelegate.minColumnWidth != minColumnWidth ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.minColumnCount != minColumnCount ||
        oldDelegate.maxColumnCount != maxColumnCount;
  }
}
