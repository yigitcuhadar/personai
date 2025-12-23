import 'dart:convert';

import 'package:http/http.dart' as http;

import 'http_logger.dart';

class OpenMeteoClient {
  OpenMeteoClient._({
    http.Client? httpClient,
    this.onHttpLog,
  }) : _httpClient = httpClient ?? http.Client();

  factory OpenMeteoClient.singleton({
    http.Client? httpClient,
    HttpLogger? onHttpLog,
  }) {
    final existing = _instance;
    if (existing != null) {
      if (onHttpLog != null && existing.onHttpLog == null) {
        existing.onHttpLog = onHttpLog;
      }
      return existing;
    }

    _instance = OpenMeteoClient._(
      httpClient: httpClient,
      onHttpLog: onHttpLog,
    );
    return _instance!;
  }

  static OpenMeteoClient? _instance;

  final http.Client _httpClient;
  HttpLogger? onHttpLog;

  Future<Map<String, dynamic>> fetchWeatherWithGeocoding(
    String location,
  ) async {
    final trimmed = location.trim();
    if (trimmed.isEmpty) throw ArgumentError('location is required');

    final geocoding = await _fetchGeocoding(trimmed);
    final results = (geocoding['results'] as List?) ?? [];
    if (results.isEmpty) throw Exception('City not found');
    final first = results.first as Map<String, dynamic>;
    final lat = first['latitude'];
    final lon = first['longitude'];
    if (lat == null || lon == null) {
      throw Exception('Latitude/longitude missing for $trimmed');
    }

    final forecast = await _fetchForecast(lat, lon);

    return {
      'geocoding': geocoding,
      'forecast': forecast,
    };
  }

  Future<Map<String, dynamic>> _fetchGeocoding(String city) async {
    final uri = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(city)}&count=1&language=en&format=json',
    );
    return _getJson(uri, 'openmeteo:geocoding');
  }

  Future<Map<String, dynamic>> _fetchForecast(num lat, num lon) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m'
      '&timezone=auto',
    );
    return _getJson(uri, 'openmeteo:forecast');
  }

  Future<Map<String, dynamic>> _getJson(Uri uri, String label) async {
    final res = await _httpClient.get(uri);
    onHttpLog?.call(label, uri, res);
    if (res.statusCode != 200) {
      throw Exception('OpenMeteo request failed (${res.statusCode})');
    }
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return decoded.cast<String, dynamic>();
    throw Exception('Unexpected OpenMeteo response for $label');
  }
}
