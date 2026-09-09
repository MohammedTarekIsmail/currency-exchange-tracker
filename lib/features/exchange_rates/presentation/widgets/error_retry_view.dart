import 'package:currency_exchange_tracker/core/theme/app_colors.dart';
import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shared failure state: an icon, a user-friendly message and a retry button.
///
/// Layout-neutral on purpose — it sizes to its content and centres itself, so
/// the caller controls the slot (the rates list hands it the whole body; the
/// detail screen wraps it in a fixed-height box where the chart would go).
/// [onRetry] is injected rather than reaching into a bloc, so the widget stays
/// reusable across features.
class ErrorRetryView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  const ErrorRetryView({
    super.key,
    required this.message,
    required this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.error),
            const Gap(12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.errorMessage,
            ),
            const Gap(16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
