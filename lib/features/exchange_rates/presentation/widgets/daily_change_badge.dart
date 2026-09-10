import 'package:currency_exchange_tracker/core/theme/app_colors.dart';
import 'package:currency_exchange_tracker/core/theme/app_palette.dart';
import 'package:currency_exchange_tracker/core/theme/app_text_styles.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/daily_change.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/daily_change_style.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/rate_format.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DailyChangeBadge extends StatelessWidget {
  const DailyChangeBadge({super.key, required this.change, this.dense = false});

  final DailyChange? change;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final change = this.change;
    final color = change?.colorIn(palette) ?? palette.unchanged;
    final style = AppTextStyles.changeValue.copyWith(
      color: color,
      fontSize: dense ? null : 13,
    );

    return Container(
      padding: dense
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppColors.badgeBackgroundOpacity),
        borderRadius: BorderRadius.circular(dense ? 6 : 8),
      ),
      child: change == null
          ? Text(dense ? '—' : 'Change unavailable', style: style)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!dense) ...[
                  Icon(change.icon, size: 16, color: color),
                  const Gap(4),
                ],
                Text(_label(change), style: style),
              ],
            ),
    );
  }

  String _label(DailyChange change) {
    final sign = change.amount > 0 ? '+' : '';
    final unit = dense ? '' : ' EGP';
    return '$sign${formatChangeAmount(change.amount)}$unit '
        '($sign${change.percent.toStringAsFixed(2)}%)';
  }
}
