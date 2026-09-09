class TrackedCurrency {
  final String code;
  final String name;

  const TrackedCurrency({required this.code, required this.name});
}

class TrackedCurrencies {
  TrackedCurrencies._();

  static const List<TrackedCurrency> all = [
    TrackedCurrency(code: 'usd', name: 'US Dollar'),
    TrackedCurrency(code: 'eur', name: 'Euro'),
    TrackedCurrency(code: 'gbp', name: 'British Pound'),
    TrackedCurrency(code: 'sar', name: 'Saudi Riyal'),
    TrackedCurrency(code: 'jpy', name: 'Japanese Yen'),
  ];
}
