import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_exchange_tracker/core/error/exceptions.dart';

abstract class ExchangeRatesLocalDataSource {
  Future<void> cacheRates(Map<String, dynamic> ratesJson);

  Future<Map<String, dynamic>> getCachedRates();

  Future<DateTime?> getLastCachedTime();
}

class ExchangeRatesLocalDataSourceImpl implements ExchangeRatesLocalDataSource {
  ExchangeRatesLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _ratesKey = 'CACHED_RATES';
  static const _timestampKey = 'CACHED_RATES_TIMESTAMP';

  @override
  Future<void> cacheRates(Map<String, dynamic> ratesJson) async {
    await _prefs.setString(_ratesKey, jsonEncode(ratesJson));
    await _prefs.setString(_timestampKey, DateTime.now().toIso8601String());
  }

  @override
  Future<Map<String, dynamic>> getCachedRates() async {
    final jsonString = _prefs.getString(_ratesKey);
    if (jsonString == null) {
      throw const CacheException('No cached rates available');
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  @override
  Future<DateTime?> getLastCachedTime() async {
    final timestampString = _prefs.getString(_timestampKey);
    if (timestampString == null) return null;
    return DateTime.parse(timestampString);
  }
}
