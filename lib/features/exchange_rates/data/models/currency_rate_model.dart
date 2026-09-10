import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_exchange_tracker/features/exchange_rates/domain/entities/daily_change.dart';

class CurrencyRateModel extends CurrencyRate {
  const CurrencyRateModel({
    required super.code,
    required super.name,
    required super.rate,
    required super.dailyChange,
    required super.lastUpdated,
  });

  factory CurrencyRateModel.fromRawRate({
    required String code,
    required String name,
    required double rawRate,
    required DailyChange? dailyChange,
    required DateTime lastUpdated,
  }) {
    return CurrencyRateModel(
      code: code.toUpperCase(),
      name: name,
      rate: 1 / rawRate,
      dailyChange: dailyChange,
      lastUpdated: lastUpdated,
    );
  }
}
