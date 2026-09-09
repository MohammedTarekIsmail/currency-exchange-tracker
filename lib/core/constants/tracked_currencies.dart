class TrackedCurrency {
  final String code;
  final String name;
  final String flagEmoji;

  const TrackedCurrency({
    required this.code,
    required this.name,
    required this.flagEmoji,
  });
}

class TrackedCurrencies {
  TrackedCurrencies._();

  static const List<TrackedCurrency> all = [
    TrackedCurrency(code: 'usd', name: 'US Dollar', flagEmoji: '🇺🇸'),
    TrackedCurrency(code: 'eur', name: 'Euro', flagEmoji: '🇪🇺'),
    TrackedCurrency(code: 'gbp', name: 'British Pound', flagEmoji: '🇬🇧'),
    TrackedCurrency(code: 'sar', name: 'Saudi Riyal', flagEmoji: '🇸🇦'),
    TrackedCurrency(code: 'jpy', name: 'Japanese Yen', flagEmoji: '🇯🇵'),
  ];
}
