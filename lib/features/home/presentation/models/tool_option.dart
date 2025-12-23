import 'package:openai_realtime/openai_realtime.dart';

class ToolOption {
  const ToolOption({
    required this.name,
    required this.label,
    required this.description,
    required this.shortDescription,
    required this.parameters,
    required this.group,
    this.family,
  });

  final String name;
  final String label;
  final String description;
  final String shortDescription;
  final Map<String, dynamic> parameters;
  final ToolGroup group;
  final String? family;

  RealtimeTool toRealtimeTool() => RealtimeTool(
    type: 'function',
    name: name,
    description: description,
    parameters: parameters,
  );
}

enum ToolGroup { api, local }

const String kToolFamilyCalendar = 'calendar';
const String kToolFamilyContacts = 'contacts';
const String kToolFamilyTogglePrefix = 'family_toggle:';
String toolFamilyToggleKey(String family) => '$kToolFamilyTogglePrefix$family';
String get kCalendarToolsToggle => toolFamilyToggleKey(kToolFamilyCalendar);
String get kContactsToolsToggle => toolFamilyToggleKey(kToolFamilyContacts);

const Map<String, String> kToolFamilyLabels = {
  kToolFamilyCalendar: 'Calendar tools',
  kToolFamilyContacts: 'Contacts tools',
};

const List<ToolOption> kToolOptions = [
  ToolOption(
    name: 'get_weather',
    label: 'Get weather',
    description:
        'Fetch current weather via Open-Meteo (geocoding + forecast). Return the raw service payload; do not convert units. Reuse previously returned data for the same location instead of calling again unless the user asks for an update.',
    shortDescription: 'Current weather via Open-Meteo',
    group: ToolGroup.api,
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
    shortDescription: 'Stock price (current or historical)',
    group: ToolGroup.api,
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
    shortDescription: 'Live football scores (country or league)',
    group: ToolGroup.api,
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
  ToolOption(
    name: 'get_calendar_events',
    label: 'Get calendar events',
    description:
        'List calendar events via device_calendar to answer scheduling questions. If no start/end is provided, default to start of today through the next 30 days. Use event_id for a single event lookup. Filter results with search_query across title/description/location.',
    shortDescription: 'List device calendar events',
    group: ToolGroup.local,
    family: kToolFamilyCalendar,
    parameters: {
      "type": "object",
      "properties": {
        "calendar_id": {
          "type": "string",
          "description":
              "Optional calendar id; leave empty to use the first writable calendar.",
        },
        "event_id": {
          "type": "string",
          "description":
              "When provided, fetch only this event id (start/end are ignored).",
        },
        "start_time": {
          "type": "string",
          "description":
              "Range start in ISO-8601 (e.g., 2025-01-01T09:00:00Z). Defaults to the start of today.",
        },
        "end_time": {
          "type": "string",
          "description":
              "Range end in ISO-8601. Defaults to 30 days after start_time when omitted.",
        },
        "search_query": {
          "type": "string",
          "description":
              "Keyword filter applied to title, description, and location.",
        },
        "max_results": {
          "type": "integer",
          "description":
              "Limit the number of events returned (minimum 1, maximum 100).",
          "minimum": 1,
          "maximum": 100,
        },
        "include_all_day": {
          "type": "boolean",
          "description":
              "Whether to include all-day events in results (default true).",
        },
      },
      "required": [],
      "additionalProperties": false,
    },
  ),
  ToolOption(
    name: 'create_calendar_event',
    label: 'Add calendar event',
    description:
        'Create a calendar event using device_calendar. Use a writable calendar (provided or default). Require title, start/end time (ISO). Respect all_day flag. Reuse chosen calendar if not provided.',
    shortDescription: 'Add an event to the device calendar',
    group: ToolGroup.local,
    family: kToolFamilyCalendar,
    parameters: {
      "type": "object",
      "properties": {
        "calendar_id": {
          "type": "string",
          "description":
              "Optional calendar id; leave empty to use the first writable calendar.",
        },
        "title": {"type": "string", "description": "Event title"},
        "description": {
          "type": "string",
          "description": "Optional event description/notes",
        },
        "start_time": {
          "type": "string",
          "description": "Start time in ISO-8601 (e.g., 2025-01-01T09:00:00Z)",
        },
        "end_time": {
          "type": "string",
          "description": "End time in ISO-8601 (e.g., 2025-01-01T10:00:00Z)",
        },
        "all_day": {
          "type": "boolean",
          "description": "Whether the event spans all day",
        },
      },
      "required": ["title", "start_time", "end_time"],
      "additionalProperties": false,
    },
  ),
  ToolOption(
    name: 'update_calendar_event',
    label: 'Update calendar event',
    description:
        'Update a calendar event via device_calendar by event_id. Merge provided fields; if calendar_id is omitted, uses first writable calendar. Start/end are ISO strings.',
    shortDescription: 'Update an event on the device calendar',
    group: ToolGroup.local,
    family: kToolFamilyCalendar,
    parameters: {
      "type": "object",
      "properties": {
        "calendar_id": {
          "type": "string",
          "description":
              "Optional calendar id; leave empty to use the first writable calendar.",
        },
        "event_id": {"type": "string", "description": "Existing event id"},
        "title": {"type": "string", "description": "New title"},
        "description": {"type": "string", "description": "New description"},
        "start_time": {
          "type": "string",
          "description": "Updated start time ISO-8601",
        },
        "end_time": {
          "type": "string",
          "description": "Updated end time ISO-8601",
        },
        "all_day": {
          "type": "boolean",
          "description": "Whether the event spans all day",
        },
      },
      "required": ["event_id"],
      "additionalProperties": false,
    },
  ),
  ToolOption(
    name: 'delete_calendar_event',
    label: 'Delete calendar event',
    description:
        'Delete a calendar event via device_calendar using event_id (and optional calendar_id).',
    shortDescription: 'Delete an event from the device calendar',
    group: ToolGroup.local,
    family: kToolFamilyCalendar,
    parameters: {
      "type": "object",
      "properties": {
        "calendar_id": {
          "type": "string",
          "description":
              "Optional calendar id; leave empty to use the first writable calendar.",
        },
        "event_id": {"type": "string", "description": "Existing event id"},
      },
      "required": ["event_id"],
      "additionalProperties": false,
    },
  ),
  ToolOption(
    name: 'get_contacts',
    label: 'Get contacts',
    description:
        'List device contacts (names, phones, emails). Filter with search_query to narrow results. Always request properties so phone/email are present.',
    shortDescription: 'List device contacts',
    group: ToolGroup.local,
    family: kToolFamilyContacts,
    parameters: {
      "type": "object",
      "properties": {
        "search_query": {
          "type": "string",
          "description":
              "Optional keyword to filter contacts by name/phone/email.",
        },
        "max_results": {
          "type": "integer",
          "description": "Limit number of contacts (1-200, default 50).",
          "minimum": 1,
          "maximum": 200,
        },
      },
      "required": [],
      "additionalProperties": false,
    },
  ),
  ToolOption(
    name: 'search_contacts',
    label: 'Search contacts',
    description:
        'Search device contacts by name, phone, or email. Always fetch phones/emails. Return best matches only.',
    shortDescription: 'Search contacts on device',
    group: ToolGroup.local,
    family: kToolFamilyContacts,
    parameters: {
      "type": "object",
      "properties": {
        "query": {
          "type": "string",
          "description": "Search term for name/phone/email (required).",
        },
        "max_results": {
          "type": "integer",
          "description": "Limit number of contacts (1-200, default 50).",
          "minimum": 1,
          "maximum": 200,
        },
      },
      "required": ["query"],
      "additionalProperties": false,
    },
  ),
  ToolOption(
    name: 'create_contact',
    label: 'Create contact',
    description:
        'Create a new contact on device with given_name (required) and optional family_name, phone_number, email, and note.',
    shortDescription: 'Add a new contact',
    group: ToolGroup.local,
    family: kToolFamilyContacts,
    parameters: {
      "type": "object",
      "properties": {
        "given_name": {
          "type": "string",
          "description": "First name of the contact.",
        },
        "family_name": {
          "type": "string",
          "description": "Last name of the contact.",
        },
        "phone_number": {
          "type": "string",
          "description": "Primary phone number.",
        },
        "email": {
          "type": "string",
          "description": "Primary email address.",
        },
        "note": {
          "type": "string",
          "description": "Optional note text.",
        },
      },
      "required": ["given_name"],
      "additionalProperties": false,
    },
  ),
  ToolOption(
    name: 'update_contact',
    label: 'Update contact',
    description:
        'Update an existing contact by contact_id. Any provided fields replace existing values (given_name, family_name, phone_number, email, note).',
    shortDescription: 'Edit an existing contact',
    group: ToolGroup.local,
    family: kToolFamilyContacts,
    parameters: {
      "type": "object",
      "properties": {
        "contact_id": {
          "type": "string",
          "description": "Existing contact id to update.",
        },
        "given_name": {
          "type": "string",
          "description": "New first name.",
        },
        "family_name": {
          "type": "string",
          "description": "New last name.",
        },
        "phone_number": {
          "type": "string",
          "description": "New primary phone number (replaces existing phones).",
        },
        "email": {
          "type": "string",
          "description": "New primary email (replaces existing emails).",
        },
        "note": {
          "type": "string",
          "description": "New note content (replaces existing notes).",
        },
      },
      "required": ["contact_id"],
      "additionalProperties": false,
    },
  ),
  ToolOption(
    name: 'delete_contact',
    label: 'Delete contact',
    description: 'Delete a contact from device by contact_id.',
    shortDescription: 'Remove a contact',
    group: ToolGroup.local,
    family: kToolFamilyContacts,
    parameters: {
      "type": "object",
      "properties": {
        "contact_id": {
          "type": "string",
          "description": "Contact id to delete.",
        },
      },
      "required": ["contact_id"],
      "additionalProperties": false,
    },
  ),
  ToolOption(
    name: 'call_contact',
    label: 'Call contact',
    description:
        'Place a direct phone call via flutter_phone_direct_caller. Provide phone_number or contact_id with at least one phone. On iOS this will fail (Android-only).',
    shortDescription: 'Call a contact number',
    group: ToolGroup.local,
    family: kToolFamilyContacts,
    parameters: {
      "type": "object",
      "properties": {
        "contact_id": {
          "type": "string",
          "description": "Contact id to call (uses first phone).",
        },
        "phone_number": {
          "type": "string",
          "description": "Explicit phone number to dial.",
        },
      },
      "required": [],
      "additionalProperties": false,
    },
  ),
  ToolOption(
    name: 'send_sms',
    label: 'Send SMS',
    description:
        'Send an SMS via flutter_sms. Provide message and at least one recipient via phone_number, contact_id, or recipients list. Uses direct send on Android, opens composer on iOS.',
    shortDescription: 'Send an SMS',
    group: ToolGroup.local,
    family: kToolFamilyContacts,
    parameters: {
      "type": "object",
      "properties": {
        "message": {
          "type": "string",
          "description": "Message text to send.",
        },
        "contact_id": {
          "type": "string",
          "description": "Contact id to use for recipient numbers.",
        },
        "phone_number": {
          "type": "string",
          "description": "Single recipient number.",
        },
        "recipients": {
          "type": "array",
          "items": {"type": "string"},
          "description": "Optional additional recipient numbers.",
        },
      },
      "required": ["message"],
      "additionalProperties": false,
    },
  ),
];

Map<String, bool> defaultToolToggles() {
  final families = <String>{};
  for (final tool in kToolOptions) {
    if (tool.family != null) families.add(tool.family!);
  }
  return {
    for (final family in families) toolFamilyToggleKey(family): true,
    for (final tool in kToolOptions) tool.name: true,
  };
}
