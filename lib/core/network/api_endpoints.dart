class ApiEndpoints {
  ApiEndpoints._();

  static const String baseCurrency = 'egp';

  static String latestRates() =>
      'https://latest.currency-api.pages.dev/v1/currencies/$baseCurrency.json';

  static String ratesForDate(DateTime date) {
    final formatted = _formatDate(date);
    return 'https://$formatted.currency-api.pages.dev/v1/currencies/$baseCurrency.json';
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
