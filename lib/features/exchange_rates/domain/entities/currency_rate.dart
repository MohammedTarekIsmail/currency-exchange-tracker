import 'package:equatable/equatable.dart';
import 'daily_change.dart';

/// A single currency pair quoted against the Egyptian Pound, ready for display.
///
/// [rate] is normalised to the format the UI shows — "1 [code] = [rate] EGP" —
/// so the raw `egp.usd` value from the API has already been inverted (1 / raw)
/// by the data layer before it reaches the domain.
class CurrencyRate extends Equatable {
  const CurrencyRate({
    required this.code,
    required this.name,
    required this.rate,
    required this.dailyChange,
    required this.lastUpdated,
  });

  /// ISO 4217 code in upper case, e.g. `USD`.
  final String code;

  /// Human-readable name, e.g. `US Dollar`.
  final String name;

  /// How many EGP one unit of this currency buys.
  final double rate;

  /// Movement since yesterday, computed by the app from two API calls.
  final DailyChange dailyChange;

  /// The day the underlying rates are for (the API updates once per day).
  final DateTime lastUpdated;

  @override
  List<Object?> get props => [code, name, rate, dailyChange, lastUpdated];
}
