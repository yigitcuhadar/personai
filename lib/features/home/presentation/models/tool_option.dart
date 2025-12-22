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
];

Map<String, bool> defaultToolToggles() => {
  for (final tool in kToolOptions) tool.name: true,
};
