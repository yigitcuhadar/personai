import 'package:openai_realtime/openai_realtime.dart';

class ToolOption {
  const ToolOption({
    required this.name,
    required this.label,
    required this.description,
    required this.shortDescription,
    required this.parameters,
  });

  final String name;
  final String label;
  final String description;
  final String shortDescription;
  final Map<String, dynamic> parameters;

  RealtimeTool toRealtimeTool() => RealtimeTool(
    type: 'function',
    name: name,
    description: description,
    parameters: parameters,
  );
}

const List<ToolOption> kToolOptions = [
  ToolOption(
    name: 'get_weather',
    label: 'Get weather',
    description:
        'Fetch current weather via Open-Meteo (geocoding + forecast). Return the raw service payload; do not convert units. Reuse previously returned data for the same location instead of calling again unless the user asks for an update.',
    shortDescription: 'Anlık hava durumu (Open-Meteo)',
    parameters: {
      "type": "object",
      "properties": {
        "location": {
          "type": "string",
          "description":
              "The city and state e.g. San Francisco, CA, but not country or country added.",
        },
        "unit": {
          "type": "string",
          "enum": ["c", "f"],
        },
      },
      "additionalProperties": false,
      "required": ["location", "unit"],
    },
  ),
  ToolOption(
    name: 'get_stock_price',
    label: 'Get stock price',
    description:
        'Get stock price (current via GLOBAL_QUOTE, historical via TIME_SERIES_DAILY). Use GLOBAL_QUOTE only for latest/today; use TIME_SERIES_DAILY for past dates. Return only the requested date entry (not the whole series). Reuse previously returned data for the same symbol/date unless the user asks for a refresh.',
    shortDescription: 'Hisse fiyatı (güncel veya geçmiş)',
    parameters: {
      "type": "object",
      "properties": {
        "symbol": {"type": "string", "description": "The stock symbol"},
        "date": {
          "type": "string",
          "description":
              "YYYY-MM-DD date if historical data is requested; TIME_SERIES_DAILY is used when a past date is provided.",
        },
        "query_type": {
          "type": "string",
          "description":
              "Force which Alpha Vantage endpoint to use. Use 'today'/'latest'/'current' for GLOBAL_QUOTE or 'history'/'historical' for TIME_SERIES_DAILY.",
          "enum": ["today", "latest", "current", "history", "historical"],
        },
      },
      "additionalProperties": false,
      "required": ["symbol"],
    },
  ),
  ToolOption(
    name: 'get_livescore',
    label: 'Live scores (AllSports)',
    description:
        'Fetch soccer/football live scores via AllSports. If league is provided, resolve league_id (and country_id from the league) and query by league; if only country is provided, resolve country_id and query by country. Return the raw API payload and any matched lookup info. Reuse previously returned data for the same country/league unless the user asks for a refresh.',
    shortDescription: 'Canlı skorlar (ülke veya lig)',
    parameters: {
      "type": "object",
      "properties": {
        "country": {
          "type": "string",
          "description":
              "Country name in English (e.g., England). Provide this when the user mentions a country.",
        },
        "league": {
          "type": "string",
          "description":
              "League name (e.g., Premier League, La Liga). Provide this when the user mentions a league.",
        },
      },
      "additionalProperties": false,
      "required": [],
    },
  ),
];

Map<String, bool> defaultToolToggles() => {
  for (final tool in kToolOptions) tool.name: true,
};
