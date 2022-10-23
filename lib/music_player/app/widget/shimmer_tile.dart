import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerTile extends StatelessWidget {
  const ShimmerTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(height: 56, width: 56, color: Colors.white),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 24,
              width: 180,
              child: Container(color: Colors.white),
            ),
          ),
        ),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 16,
              width: 120,
              child: Container(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
