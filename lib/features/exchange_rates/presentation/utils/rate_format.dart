/// How EGP amounts are rendered across the app.
///
/// The pairs tracked here span three orders of magnitude.
library;

/// A headline rate, e.g. `51.19` in "1 USD = 51.19 EGP".
String formatRate(double rate) => rate.toStringAsFixed(2);

/// A day-over-day change in EGP, unsigned formatting (callers prepend `+`).
///
/// Precision follows the magnitude, because the daily move is roughly 0.3% of
/// the rate whatever the currency: USD moves ~0.17 EGP a day, but JPY moves
/// ~0.001. At a flat 2 decimals JPY's change renders as "0.00" every single
/// day, which reads as "no movement" next to a non-zero percentage.
String formatChangeAmount(double amount) {
  final magnitude = amount.abs();
  if (magnitude >= 0.1) return amount.toStringAsFixed(2);
  if (magnitude >= 0.01) return amount.toStringAsFixed(3);
  if (magnitude >= 0.001) return amount.toStringAsFixed(4);
  if (magnitude > 0) return amount.toStringAsFixed(5);
  return amount.toStringAsFixed(2); // exactly flat -> "0.00"
}

/// A chart axis or tooltip value. Kept tighter than [formatRate] so stacked
/// axis labels stay narrow and uniform.
String formatAxisRate(double value) {
  if (value >= 100) return value.toStringAsFixed(0);
  if (value >= 10) return value.toStringAsFixed(1);
  if (value >= 1) return value.toStringAsFixed(2);
  return value.toStringAsFixed(3);
}
