import 'package:currency_exchange_tracker/features/exchange_rates/presentation/utils/rate_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatRate', () {
    test('uses the 2-decimal display format from the brief', () {
      expect(formatRate(51.1933), '51.19');
      expect(formatRate(0.3337), '0.33');
    });
  });

  group('formatChangeAmount', () {
    test('keeps 2 decimals for the currencies that move by more than 0.1', () {
      expect(formatChangeAmount(0.17040), '0.17'); // USD, a typical day
      expect(formatChangeAmount(0.27642), '0.28'); // GBP
      expect(formatChangeAmount(-1.5), '-1.50');
    });

    test('adds precision as the movement gets smaller', () {
      expect(formatChangeAmount(0.04544), '0.045'); // SAR
      expect(formatChangeAmount(0.00112), '0.0011'); // JPY — was "0.00"
      expect(formatChangeAmount(0.00004), '0.00004');
    });

    test('never renders a real movement as zero', () {
      for (final amount in [0.00112, -0.00112, 0.009, 0.0001]) {
        expect(formatChangeAmount(amount), isNot(matches(r'^-?0\.0*$')));
      }
    });

    test('renders an exactly flat day as 0.00', () {
      expect(formatChangeAmount(0), '0.00');
    });
  });

  group('formatAxisRate', () {
    test('trades decimals for width as values grow', () {
      expect(formatAxisRate(120.5), '121');
      expect(formatAxisRate(51.19), '51.2');
      expect(formatAxisRate(1.5), '1.50');
      expect(formatAxisRate(0.3337), '0.334');
    });
  });
}
