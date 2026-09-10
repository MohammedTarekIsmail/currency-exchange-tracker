import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';
import 'package:currency_exchange_tracker/core/theme/app_palette.dart';

const double kChartHeight = 220;

class HistoricalRateChartLoading extends StatelessWidget {
  const HistoricalRateChartLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Shimmer.fromColors(
      baseColor: palette.shimmerBase,
      highlightColor: palette.shimmerHighlight,
      child: SizedBox(
        height: kChartHeight,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: palette.shimmerBase,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 7; i++)
                    Container(
                      width: 26,
                      height: 10,
                      decoration: BoxDecoration(
                        color: palette.shimmerBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
