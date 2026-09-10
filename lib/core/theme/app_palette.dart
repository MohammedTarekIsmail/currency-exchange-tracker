import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.textSecondary,
    required this.strengthening,
    required this.weakening,
    required this.unchanged,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.chartGridLine,
    required this.chartTooltipBackground,
    required this.chartTooltipText,
    required this.cardShadow,
  });

  final Color textSecondary;
  final Color strengthening;
  final Color weakening;
  final Color unchanged;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color chartGridLine;
  final Color chartTooltipBackground;
  final Color chartTooltipText;
  final Color cardShadow;

  static const AppPalette light = AppPalette(
    textSecondary: AppColors.textSecondary,
    strengthening: AppColors.strengthening,
    weakening: AppColors.weakening,
    unchanged: AppColors.unchanged,
    shimmerBase: AppColors.shimmerBase,
    shimmerHighlight: AppColors.shimmerHighlight,
    chartGridLine: AppColors.chartGridLine,
    chartTooltipBackground: AppColors.chartTooltipBackground,
    chartTooltipText: AppColors.chartTooltipText,
    cardShadow: AppColors.cardShadow,
  );

  static const AppPalette dark = AppPalette(
    textSecondary: AppColors.textSecondaryDark,
    strengthening: AppColors.strengtheningDark,
    weakening: AppColors.weakeningDark,
    unchanged: AppColors.unchangedDark,
    shimmerBase: AppColors.shimmerBaseDark,
    shimmerHighlight: AppColors.shimmerHighlightDark,
    chartGridLine: AppColors.chartGridLineDark,
    chartTooltipBackground: AppColors.chartTooltipBackgroundDark,
    chartTooltipText: AppColors.chartTooltipTextDark,
    cardShadow: AppColors.cardShadowDark,
  );

  @override
  AppPalette copyWith({
    Color? textSecondary,
    Color? strengthening,
    Color? weakening,
    Color? unchanged,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? chartGridLine,
    Color? chartTooltipBackground,
    Color? chartTooltipText,
    Color? cardShadow,
  }) {
    return AppPalette(
      textSecondary: textSecondary ?? this.textSecondary,
      strengthening: strengthening ?? this.strengthening,
      weakening: weakening ?? this.weakening,
      unchanged: unchanged ?? this.unchanged,
      shimmerBase: shimmerBase ?? this.shimmerBase,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      chartGridLine: chartGridLine ?? this.chartGridLine,
      chartTooltipBackground:
          chartTooltipBackground ?? this.chartTooltipBackground,
      chartTooltipText: chartTooltipText ?? this.chartTooltipText,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      strengthening: Color.lerp(strengthening, other.strengthening, t)!,
      weakening: Color.lerp(weakening, other.weakening, t)!,
      unchanged: Color.lerp(unchanged, other.unchanged, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
      chartGridLine: Color.lerp(chartGridLine, other.chartGridLine, t)!,
      chartTooltipBackground: Color.lerp(
        chartTooltipBackground,
        other.chartTooltipBackground,
        t,
      )!,
      chartTooltipText: Color.lerp(
        chartTooltipText,
        other.chartTooltipText,
        t,
      )!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;

  ColorScheme get colors => Theme.of(this).colorScheme;
}
