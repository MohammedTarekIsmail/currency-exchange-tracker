import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:currency_exchange_tracker/core/theme/app_palette.dart';
import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';

class CachedDataBanner extends StatelessWidget {
  final DateTime? cachedAt;
  final bool isFromCache;
  final bool isOffline;

  const CachedDataBanner({
    super.key,
    required this.cachedAt,
    required this.isFromCache,
    required this.isOffline,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = cachedAt != null
        ? DateFormat('MMM d, h:mm a').format(cachedAt!)
        : 'unknown time';
    final message = isFromCache
        ? 'Showing cached data · $formattedTime'
        : "You're offline · rates may be out of date";

    final palette = context.palette;

    return Container(
      width: double.infinity,
      color: palette.unchanged.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.wifi_off : Icons.cloud_off,
            size: 16,
            color: palette.textSecondary,
          ),
          const Gap(8),
          Expanded(child: Text(message, style: AppTextStyles.currencyCode)),
        ],
      ),
    );
  }
}
