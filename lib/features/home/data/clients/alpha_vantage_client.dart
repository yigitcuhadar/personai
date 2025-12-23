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
      final selected = _selectDailyEntry(response, normalizedDate);
      return {
        'symbol': normalizedSymbol,
        'endpoint': 'TIME_SERIES_DAILY',
        if (normalizedDate != null) 'requested_date': normalizedDate,
        if (normalizedQuery != null) 'query_type': normalizedQuery,
        'date': selected.date,
        'price': selected.data,
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

  _DailySelection _selectDailyEntry(
    Map<String, dynamic> response,
    String? requestedDate,
  ) {
    final series =
        (response['Time Series (Daily)'] ?? response['time_series_daily'])
            as Map?;
    if (series == null) {
      throw Exception('TIME_SERIES_DAILY payload missing');
    }
    final daily = series.cast<String, dynamic>();
    String? chosenKey = requestedDate;
    Map<String, dynamic>? chosenData;

    if (chosenKey != null && daily.containsKey(chosenKey)) {
      chosenData = _asStringMap(daily[chosenKey]);
    } else {
      // pick most recent date
      final keys = daily.keys.toList()
        ..sort(
          (a, b) {
            final da = DateTime.tryParse(a);
            final db = DateTime.tryParse(b);
            if (da == null || db == null) return b.compareTo(a);
            return db.compareTo(da); // descending
          },
        );
      if (keys.isEmpty) {
        throw Exception('TIME_SERIES_DAILY has no entries');
      }
      chosenKey = keys.first;
      chosenData = _asStringMap(daily[chosenKey]);
    }

    if (chosenData == null) {
      throw Exception('No data found for requested date');
    }

    return _DailySelection(date: chosenKey, data: chosenData);
  }

  Map<String, dynamic> _asStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    throw Exception('Unexpected daily entry type');
  }
}

class _DailySelection {
  _DailySelection({
    required this.date,
    required this.data,
  });

  final String? date;
  final Map<String, dynamic> data;
}
