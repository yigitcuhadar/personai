import 'dart:convert';

import 'package:http/http.dart' as http;

import 'http_logger.dart';

class AllSportsListResponse {
  const AllSportsListResponse({
    required this.items,
  });

  final List<Map<String, dynamic>> items;
}

class AllSportsApiClient {
  AllSportsApiClient._({
    String? apiKey,
    http.Client? httpClient,
    this.onHttpLog,
  }) : _apiKey = apiKey?.trim(),
       _httpClient = httpClient ?? http.Client();

  factory AllSportsApiClient.singleton({
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

    _instance = AllSportsApiClient._(
      apiKey: apiKey,
      httpClient: httpClient,
      onHttpLog: onHttpLog,
    );
    return _instance!;
  }

  static AllSportsApiClient? _instance;

  String? _apiKey;
  final http.Client _httpClient;
  HttpLogger? onHttpLog;
  AllSportsListResponse? _countriesCache;
  final Map<String, AllSportsListResponse> _leaguesCache = {};
  final Map<String, Map<String, dynamic>> _livescoreCache = {};

  Future<AllSportsListResponse> fetchCountries() async {
    if (_countriesCache != null) return _countriesCache!;

    final uri = _buildUri('Countries');
    final json = await _getJson(uri, 'allsports:countries');
    _countriesCache = AllSportsListResponse(
      items: _extractResultList(json, 'countries'),
    );
    return _countriesCache!;
  }

  Future<AllSportsListResponse> fetchLeagues({String? countryId}) async {
    final cacheKey = countryId?.trim() ?? '';
    final cached = _leaguesCache[cacheKey];
    if (cached != null) return cached;

    final uri = _buildUri(
      'Leagues',
      extraParams: {if (countryId != null) 'countryId': countryId},
    );
    final json = await _getJson(uri, 'allsports:leagues');
    final response = AllSportsListResponse(
      items: _extractResultList(json, 'leagues'),
    );
    _leaguesCache[cacheKey] = response;
    return response;
  }

  Future<Map<String, dynamic>> fetchLiveScoreByQuery({
    String? countryName,
    String? leagueName,
  }) async {
    final normalizedCountry = _normalizeName(countryName);
    final normalizedLeague = _normalizeName(leagueName);
    final wantsLeague = normalizedLeague != null;
    final wantsCountry = normalizedCountry != null;

    if (!wantsLeague && !wantsCountry) {
      throw ArgumentError('country or league is required');
    }

    AllSportsListResponse? countriesResponse;
    AllSportsListResponse? leaguesResponse;
    Map<String, dynamic>? matchedCountry;
    Map<String, dynamic>? matchedLeague;

    String? countryId;
    String? leagueId;

    if (wantsLeague) {
      final liveCacheKey =
          'league:${normalizedLeague}_${normalizedCountry ?? ''}';
      final cachedLive = _livescoreCache[liveCacheKey];
      if (cachedLive != null) return cachedLive;

      leaguesResponse = await fetchLeagues();

      List<Map<String, dynamic>> leaguePool = leaguesResponse.items;
      if (normalizedCountry != null) {
        leaguePool = leaguePool
            .where(
              (league) => _matchesName(
                league['country_name'] as String?,
                normalizedCountry,
              ),
            )
            .toList();
      }

      matchedLeague = _matchByName(
        leaguePool.isNotEmpty ? leaguePool : leaguesResponse.items,
        'league_name',
        normalizedLeague,
      );
      leagueId = matchedLeague?['league_key']?.toString();
      countryId = matchedLeague?['country_key']?.toString();
      matchedCountry = {
        if (countryId != null) 'country_key': countryId,
        'country_name': matchedLeague?['country_name'],
      };

      if (leagueId == null || leagueId.isEmpty) {
        throw Exception('League not found for "$normalizedLeague"');
      }

      final livescore = await _fetchLiveScore(
        countryId: countryId,
        leagueId: leagueId,
      );

      final payload = {
        'input': {'country': normalizedCountry, 'league': normalizedLeague},
        if (matchedCountry != null) 'matched_country': matchedCountry,
        if (matchedLeague != null) 'matched_league': matchedLeague,
        'livescore': livescore,
      };
      _livescoreCache[liveCacheKey] = payload;
      return payload;
    } else {
      final liveCacheKey = 'country:$normalizedCountry';
      final cachedLive = _livescoreCache[liveCacheKey];
      if (cachedLive != null) return cachedLive;

      countriesResponse = await fetchCountries();
      matchedCountry = _matchByName(
        countriesResponse.items,
        'country_name',
        normalizedCountry!,
      );
      countryId = matchedCountry?['country_key']?.toString();

      if (countryId == null || countryId.isEmpty) {
        throw Exception('Country not found for "$normalizedCountry"');
      }
      final livescore = await _fetchLiveScore(
        countryId: countryId,
        leagueId: leagueId,
      );

      final payload = {
        'input': {'country': normalizedCountry, 'league': normalizedLeague},
        if (matchedCountry != null) 'matched_country': matchedCountry,
        if (matchedLeague != null) 'matched_league': matchedLeague,
        'livescore': livescore,
      };
      _livescoreCache[liveCacheKey] = payload;
      return payload;
    }
  }

  Future<Map<String, dynamic>> _fetchLiveScore({
    String? countryId,
    String? leagueId,
  }) async {
    if ((countryId == null || countryId.isEmpty) &&
        (leagueId == null || leagueId.isEmpty)) {
      throw ArgumentError('countryId or leagueId is required');
    }

    final uri = _buildUri(
      'Livescore',
      extraParams: {
        if (countryId != null && countryId.isNotEmpty) 'countryId': countryId,
        if (leagueId != null && leagueId.isNotEmpty) 'leagueId': leagueId,
      },
    );
    final json = await _getJson(uri, 'allsports:livescore');

    if (json is Map && json['error'] != null) {
      throw Exception('AllSports Livescore error: ${json['error']}');
    }
    if (json is Map<String, dynamic>) return json;
    if (json is Map) return json.cast<String, dynamic>();
    throw Exception('Unexpected AllSports livescore response type');
  }

  Uri _buildUri(String met, {Map<String, String>? extraParams}) {
    final apiKey = _requireApiKey();
    return Uri.parse(
      'https://apiv2.allsportsapi.com/football',
    ).replace(
      queryParameters: {
        'met': met,
        'APIkey': apiKey,
        if (extraParams != null) ...extraParams,
      },
    );
  }

  String _requireApiKey() {
    final key = _apiKey?.trim();
    if (key == null || key.isEmpty) {
      throw Exception('AllSports API key not configured');
    }
    return key;
  }

  String? _normalizeName(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  Future<dynamic> _getJson(Uri uri, String label) async {
    final res = await _httpClient.get(uri);
    onHttpLog?.call(label, uri, res);
    if (res.statusCode != 200) {
      throw Exception('AllSports request failed (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  List<Map<String, dynamic>> _extractResultList(dynamic json, String context) {
    if (json is Map && json['error'] != null) {
      throw Exception('AllSports $context error: ${json['error']}');
    }
    final result = json is Map ? json['result'] : null;
    final list = result is List ? result : (json is List ? json : null);
    if (list == null) {
      throw Exception('AllSports $context response missing result list');
    }
    return list.map<Map<String, dynamic>>((item) {
      if (item is Map<String, dynamic>) return item;
      if (item is Map) return item.cast<String, dynamic>();
      throw Exception('AllSports $context item is not a map');
    }).toList();
  }

  Map<String, dynamic>? _matchByName(
    List<Map<String, dynamic>> items,
    String key,
    String query,
  ) {
    final normalized = query.toLowerCase();
    for (final item in items) {
      final value = ((item[key] as String?) ?? '').toLowerCase();
      if (value == normalized) return item;
    }
    for (final item in items) {
      final value = ((item[key] as String?) ?? '').toLowerCase();
      if (value.contains(normalized)) return item;
    }
    return null;
  }

  bool _matchesName(String? value, String query) {
    final normalizedValue = (value ?? '').toLowerCase();
    final normalizedQuery = query.toLowerCase();
    return normalizedValue == normalizedQuery ||
        normalizedValue.contains(normalizedQuery);
  }
}
