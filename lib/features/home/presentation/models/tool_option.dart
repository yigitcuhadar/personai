import 'package:openai_realtime/openai_realtime.dart';

class ToolOption {
  const ToolOption({
    required this.name,
    required this.label,
    required this.description,
    required this.parameters,
  });

  final String name;
  final String label;
  final String description;
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
    description: 'Determine weather in my location',
    parameters: {
      "type": "object",
      "properties": {
        "location": {
          "type": "string",
          "description": "The city and state e.g. San Francisco, CA",
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
    description: 'Get the current stock price',
    parameters: {
      "type": "object",
      "properties": {
        "symbol": {"type": "string", "description": "The stock symbol"},
      },
      "additionalProperties": false,
      "required": ["symbol"],
    },
  ),
  ToolOption(
    name: 'get_sports_scores',
    label: 'Get sports scores',
    description: 'Get fixtures/scores for a league on a given date',
    parameters: {
      "type": "object",
      "properties": {
        "league_id": {
          "type": "string",
          "description": "League id (api-football.com)",
        },
        "date": {
          "type": "string",
          "description": "Date in YYYY-MM-DD; defaults to today",
        },
      },
      "additionalProperties": false,
      "required": ["league_id"],
    },
  ),
  ToolOption(
    name: 'get_livescore',
    label: 'Live scores (AllSports)',
    description: 'Fetch live scores for a country (soccer/football)',
    parameters: {
      "type": "object",
      "properties": {
        "country": {
          "type": "string",
          "description": "Country name in English (e.g., England)",
        },
      },
      "additionalProperties": false,
      "required": ["country"],
    },
  ),
];

Map<String, bool> defaultToolToggles() => {
  for (final tool in kToolOptions) tool.name: true,
};
