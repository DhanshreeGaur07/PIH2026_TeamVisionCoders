import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

/// Shimmer skeleton placeholder for loading states — neo brutal light theme.
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceLight,
      highlightColor: AppTheme.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppTheme.borderLight, width: 2),
        ),
      ),
    );
  }
}

/// Shimmer card skeleton — mimics a brutal card while data loads.
class ShimmerCard extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? margin;

  const ShimmerCard({super.key, this.height = 120, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: AppTheme.surfaceLight,
        highlightColor: AppTheme.surface,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderLight, width: 2),
          ),
        ),
      ),
    );
  }
}

/// A shimmer grid for product/stat cards.
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final double childAspectRatio;
  final int crossAxisCount;

  const ShimmerGrid({
    super.key,
    this.itemCount = 4,
    this.childAspectRatio = 1.0,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppTheme.surfaceLight,
        highlightColor: AppTheme.surface,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.borderLight, width: 2),
          ),
        ),
      ),
    );
  }
}

/// Shimmer list — vertical list of shimmer cards.
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerList({super.key, this.itemCount = 5, this.itemHeight = 80});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (i) => ShimmerCard(
          height: itemHeight,
          margin: const EdgeInsets.only(bottom: 10),
        ),
      ),
    );
  }
}
