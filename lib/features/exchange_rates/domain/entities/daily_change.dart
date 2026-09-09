import 'package:equatable/equatable.dart';

/// The day-over-day movement of a currency pair, computed by the app (not the
/// API) from today's rate versus yesterday's rate.
///
/// Both fields are expressed in the same "EGP per 1 unit of the foreign
/// currency" terms as [CurrencyRate.rate]:
///  * [amount] is `todayRate - yesterdayRate`.
///  * [percent] is that difference relative to yesterday's rate, as a
///    percentage (e.g. `1.5` means +1.5%).
///
/// Sign semantics are inverted relative to the foreign currency because the
/// rate is quoted in EGP: when it takes *fewer* EGP to buy one unit of the
/// foreign currency the EGP has strengthened, so a negative [amount] is good
/// news for the EGP.
class DailyChange extends Equatable {
  const DailyChange({required this.amount, required this.percent});

  /// A flat day with no movement.
  const DailyChange.zero() : amount = 0, percent = 0;

  final double amount;
  final double percent;

  /// Fewer EGP needed per foreign unit than yesterday — render this green.
  bool get isEgpStrengthening => amount < 0;

  /// More EGP needed per foreign unit than yesterday — render this red.
  bool get isEgpWeakening => amount > 0;

  bool get isUnchanged => amount == 0;

  @override
  List<Object?> get props => [amount, percent];
}
