import 'dart:convert';

import 'package:http/http.dart' as http;

import 'http_logger.dart';

class AlphaVantageClient {
  AlphaVantageClient._({
    String? apiKey,
    http.Client? httpClient,
    this.onHttpLog,
  }) : _apiKey = apiKey?.trim(),
       _httpClient = httpClient ?? http.Client();

  factory AlphaVantageClient.singleton({
    String? apiKey,
    http.Client? httpClient,
    HttpLogger? onHttpLog,
  }) {
    final existing = _instance;
    if (existing != null) {
      if (apiKey != null &&
          apiKey.trim().isNotEmpty &&
          existing._apiKey == null) {
        existing._apiKey = apiKey.trim();
      }
      if (onHttpLog != null && existing.onHttpLog == null) {
        existing.onHttpLog = onHttpLog;
      }
      return existing;
    }

    _instance = AlphaVantageClient._(
      apiKey: apiKey,
      httpClient: httpClient,
      onHttpLog: onHttpLog,
    );
    return _instance!;
  }

  static AlphaVantageClient? _instance;

  String? _apiKey;
  final http.Client _httpClient;
  HttpLogger? onHttpLog;
  final Map<String, Map<String, dynamic>> _timeSeriesCache = {};
  final Map<String, Map<String, dynamic>> _globalQuoteCache = {};

  Future<Map<String, dynamic>> fetchStock({
    required String? symbol,
    String? date,
    String? queryType,
  }) async {
    final normalizedSymbol = _normalizeSymbol(symbol);
    final normalizedQuery = queryType?.trim().toLowerCase();
    final normalizedDate = date?.trim();

    final isHistorical = switch (normalizedQuery) {
      'historical' || 'history' => true,
      'today' || 'latest' || 'current' => false,
      _ => _shouldUseHistorical(normalizedDate),
    };

    if (isHistorical) {
      final cached = _timeSeriesCache[normalizedSymbol];
      final response = cached ?? await fetchTimeSeriesDaily(normalizedSymbol);
      _timeSeriesCache[normalizedSymbol] = response;
      return {
        'symbol': normalizedSymbol,
        'endpoint': 'TIME_SERIES_DAILY',
        if (normalizedDate != null) 'requested_date': normalizedDate,
        if (normalizedQuery != null) 'query_type': normalizedQuery,
        'response': response,
        'cached': cached != null,
      };
    }

    final cached = _globalQuoteCache[normalizedSymbol];
    final response = cached ?? await fetchGlobalQuote(normalizedSymbol);
    _globalQuoteCache[normalizedSymbol] = response;
    return {
      'symbol': normalizedSymbol,
      'endpoint': 'GLOBAL_QUOTE',
      if (normalizedDate != null) 'requested_date': normalizedDate,
      if (normalizedQuery != null) 'query_type': normalizedQuery,
      'response': response,
      'cached': cached != null,
    };
  }

  Future<Map<String, dynamic>> fetchGlobalQuote(String symbol) async {
    final normalizedSymbol = _normalizeSymbol(symbol);
    final key = _requireApiKey();
    final uri = Uri.parse(
      'https://www.alphavantage.co/query'
      '?function=GLOBAL_QUOTE'
      '&symbol=$normalizedSymbol'
      '&apikey=$key',
    );
    return _getJson(uri, 'alphavantage:global_quote');
  }

  Future<Map<String, dynamic>> fetchTimeSeriesDaily(String symbol) async {
    final normalizedSymbol = _normalizeSymbol(symbol);
    final key = _requireApiKey();
    final uri = Uri.parse(
      'https://www.alphavantage.co/query'
      '?function=TIME_SERIES_DAILY'
      '&symbol=$normalizedSymbol'
      '&apikey=$key',
    );
    return _getJson(uri, 'alphavantage:time_series_daily');
  }

  String _requireApiKey() {
    final key = _apiKey?.trim();
    if (key == null || key.isEmpty) {
      throw Exception('Alpha Vantage API key not configured');
    }
    return key;
  }

  String _normalizeSymbol(String? symbol) {
    final trimmed = symbol?.trim().toUpperCase() ?? '';
    if (trimmed.isEmpty) {
      throw ArgumentError('symbol is required');
    }
    return trimmed;
  }

  bool _shouldUseHistorical(String? date) {
    if (date == null || date.isEmpty) return false;
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return true;

    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final target = DateTime.utc(parsed.year, parsed.month, parsed.day);
    return target.isBefore(today) || target.isAfter(today);
  }

  Future<Map<String, dynamic>> _getJson(Uri uri, String label) async {
    final res = await _httpClient.get(uri);
    onHttpLog?.call(label, uri, res);
    if (res.statusCode != 200) {
      throw Exception('Alpha Vantage request failed (${res.statusCode})');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw Exception('Unexpected Alpha Vantage response for $label');
  }
}
