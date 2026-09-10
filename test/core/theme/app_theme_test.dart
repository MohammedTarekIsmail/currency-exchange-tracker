import 'package:currency_exchange_tracker/core/theme/app_palette.dart';
import 'package:currency_exchange_tracker/core/theme/app_theme.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/daily_change.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/presentation/widgets/currency_rate_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final themes = {'light': AppTheme.light, 'dark': AppTheme.dark};

  group('both themes register AppPalette', () {
    themes.forEach((name, theme) {
      test(name, () {
        expect(theme.extension<AppPalette>(), isNotNull);
      });
    });
  });

  test('the two themes carry the brightness they claim', () {
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });

  group('a rate row builds under', () {
    final rate = CurrencyRate(
      code: 'USD',
      name: 'US Dollar',
      rate: 51.19,
      dailyChange: const DailyChange(amount: 0.17, percent: 0.33),
      lastUpdated: DateTime(2026, 9, 10),
    );

    themes.forEach((name, theme) {
      testWidgets(name, (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: CurrencyRateListItem(rate: rate, onTap: () {}),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        expect(find.text('US Dollar'), findsOneWidget);
        expect(find.text('51.19 EGP'), findsOneWidget);
      });
    });
  });

  testWidgets('an unknown change renders as a dash, not a zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: CurrencyRateListItem(
            rate: CurrencyRate(
              code: 'JPY',
              name: 'Japanese Yen',
              rate: 0.33,
              dailyChange: null,
              lastUpdated: DateTime(2026, 9, 10),
            ),
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('—'), findsOneWidget);
    expect(find.textContaining('0.00'), findsNothing);
  });
}
