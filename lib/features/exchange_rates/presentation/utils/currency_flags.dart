const Map<String, String> currencyFlags = {
  'USD': '🇺🇸',
  'EUR': '🇪🇺',
  'GBP': '🇬🇧',
  'SAR': '🇸🇦',
  'JPY': '🇯🇵',
};

String flagFor(String code) => currencyFlags[code.toUpperCase()] ?? '🏳️';
