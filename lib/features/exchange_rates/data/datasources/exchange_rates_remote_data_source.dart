import 'dart:io';
import 'package:dio/dio.dart';
import 'package:currency_exchange_tracker/core/error/exceptions.dart';
import 'package:currency_exchange_tracker/core/network/api_endpoints.dart';

/// Thin transport layer over the currency-api endpoints. It only fetches and
/// shape-checks the raw JSON; inverting rates, extracting the tracked
/// currencies and computing the daily change all happen in the repository.
///
/// Every method returns the full decoded response body, which looks like:
/// ```json
/// { "date": "2026-06-01", "egp": { "usd": 0.0192, "eur": 0.0165, ... } }
/// ```
/// The `date` field is kept so the repository can surface "last updated".
abstract class ExchangeRatesRemoteDataSource {
  /// Today's rates for every currency against EGP.
  Future<Map<String, dynamic>> fetchLatestRates();

  /// Rates for every currency against EGP on a single [date].
  Future<Map<String, dynamic>> fetchRatesForDate(DateTime date);
}

class ExchangeRatesRemoteDataSourceImpl
    implements ExchangeRatesRemoteDataSource {
  ExchangeRatesRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> fetchLatestRates() {
    return _getRatesBody(ApiEndpoints.latestRates());
  }

  @override
  Future<Map<String, dynamic>> fetchRatesForDate(DateTime date) {
    return _getRatesBody(ApiEndpoints.ratesForDate(date));
  }

  Future<Map<String, dynamic>> _getRatesBody(String url) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(url);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }

    // A Dio instance with a lenient `validateStatus` would not throw on a bad
    // status, so guard it explicitly rather than trusting the default.
    if (response.statusCode != 200) {
      throw ServerException(
        'Request to $url failed with status ${response.statusCode}',
      );
    }

    final data = response.data;
    if (data is! Map) {
      throw const ServerException(
        'Unexpected response format: expected a JSON object',
      );
    }

    final body = Map<String, dynamic>.from(data);
    if (body[ApiEndpoints.baseCurrency] is! Map) {
      throw ServerException(
        'Unexpected response shape: missing "${ApiEndpoints.baseCurrency}" '
        'rates object',
      );
    }

    return body;
  }

  /// Connection/timeout problems become [NetworkException]; anything the server
  /// did wrong (bad status, unusable payload) becomes [ServerException].
  Exception _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkException(
          'Connection timed out. Please try again.',
        );
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badCertificate:
        return const NetworkException(
          'Could not establish a secure connection.',
        );
      case DioExceptionType.badResponse:
        return ServerException(
          'Server responded with status ${e.response?.statusCode}.',
        );
      case DioExceptionType.cancel:
        return const ServerException('The request was cancelled.');
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return const NetworkException();
        }
        return ServerException(
          e.message ??
              'An unexpected error occurred while contacting the server.',
        );
    }
  }
}
