import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Row(
          spacing: 8,
          children: [
            Container(
              height: 100,
              width: 150,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(5)),
            ),
            Expanded(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 6,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                ),
                Container(
                  height: 16,
                  width: 60,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5)),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 20,
                  children: [
                    Flexible(
                        child: Container(
                      height: 24,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                    )),
                    Flexible(
                        child: Container(
                      height: 24,
                      width: 60,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5)),
                    )),
                  ],
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
