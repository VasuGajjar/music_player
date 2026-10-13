import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerTile extends StatelessWidget {
  final Size leading;

  const ShimmerTile({Key? key, this.leading = const Size(48, 48)}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget bar(double height, double width) => Container(
          height: height,
          width: width,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
        );

    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surfaceContainerHigh,
      child: ListTile(
        leading: bar(leading.height, leading.width),
        title: Align(alignment: Alignment.centerLeft, child: bar(14, 160)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Align(alignment: Alignment.centerLeft, child: bar(12, 100)),
        ),
      ),
    );
  }
}
