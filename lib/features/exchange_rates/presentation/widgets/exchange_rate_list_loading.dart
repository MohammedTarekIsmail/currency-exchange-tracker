import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:currency_exchange_tracker/core/theme/app_palette.dart';

class ExchangeRatesListLoading extends StatelessWidget {
  const ExchangeRatesListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Shimmer.fromColors(
      baseColor: palette.shimmerBase,
      highlightColor: palette.shimmerHighlight,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, index) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: palette.shimmerBase),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 100,
                        color: palette.shimmerBase,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 50,
                        color: palette.shimmerBase,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: 14,
                      width: 60,
                      color: palette.shimmerBase,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 18,
                      width: 70,
                      color: palette.shimmerBase,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
