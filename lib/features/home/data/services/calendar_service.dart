import 'package:device_calendar/device_calendar.dart';

class CalendarService {
  CalendarService({
    DeviceCalendarPlugin? plugin,
  }) : _plugin = plugin ?? DeviceCalendarPlugin();

  final DeviceCalendarPlugin _plugin;
  String? _cachedCalendarId;

  Future<Map<String, dynamic>> listEvents({
    String? calendarId,
    String? eventId,
    String? startTime,
    String? endTime,
    String? searchQuery,
    int? maxResults,
    bool includeAllDay = true,
  }) async {
    final normalizedEventId = _normalizedId(eventId);
    final calendar = await _resolveCalendarId(calendarId);
    final params = _buildRetrieveParams(
      eventId: normalizedEventId,
      startTime: startTime,
      endTime: endTime,
    );
    final result = await _plugin.retrieveEvents(calendar, params);
    if (result.isSuccess && result.data != null) {
      final filtered = _filterAndSortEvents(
        result.data!.toList(),
        searchQuery: searchQuery,
        includeAllDay: includeAllDay,
      );
      final limit = _normalizeLimit(maxResults);
      final limited = filtered
          .take(limit)
          .map((event) => _eventToJson(event, calendarId: calendar))
          .toList();
      return {
        'calendar_id': calendar,
        if (normalizedEventId != null) 'event_id': normalizedEventId,
        'count': limited.length,
        'has_more': filtered.length > limited.length,
        'events': limited,
      };
    }
    throw Exception(
      result.errors.isNotEmpty
          ? result.errors.first.errorMessage
          : 'Retrieve events failed',
    );
  }

  Future<Map<String, dynamic>> createEvent({
    String? calendarId,
    required String title,
    String? description,
    required String startTime,
    required String endTime,
    bool allDay = false,
  }) async {
    final calendar = await _resolveCalendarId(calendarId);
    final start = _parseDate(startTime, 'startTime');
    final end = _parseDate(endTime, 'endTime');
    if (!allDay && start.isAfter(end)) {
      throw ArgumentError('startTime must be before endTime');
    }

    final event = Event(
      calendar,
      title: title.trim(),
      description: description?.trim(),
      start: start,
      end: end,
      allDay: allDay,
    );
    final result = await _plugin.createOrUpdateEvent(event);
    if (result?.isSuccess == true && result?.data != null) {
      event.eventId = result!.data;
      return _eventPayload(calendar, event);
    }
    throw Exception(
      (result?.errors.isNotEmpty ?? false)
          ? result!.errors.first.errorMessage
          : 'Create event failed',
    );
  }

  Future<Map<String, dynamic>> updateEvent({
    String? calendarId,
    required String eventId,
    String? title,
    String? description,
    String? startTime,
    String? endTime,
    bool? allDay,
  }) async {
    final calendar = await _resolveCalendarId(calendarId);
    final existing = await _loadEvent(calendar, eventId);
    if (title != null) existing.title = title.trim();
    if (description != null) existing.description = description.trim();
    if (allDay != null) existing.allDay = allDay;
    if (startTime != null) existing.start = _parseDate(startTime, 'startTime');
    if (endTime != null) existing.end = _parseDate(endTime, 'endTime');
    if (existing.start != null &&
        existing.end != null &&
        !(existing.allDay ?? false) &&
        existing.start!.isAfter(existing.end!)) {
      throw ArgumentError('startTime must be before endTime');
    }

    final result = await _plugin.createOrUpdateEvent(existing);
    if (result?.isSuccess == true && result?.data != null) {
      existing.eventId = result!.data;
      return _eventPayload(calendar, existing);
    }
    throw Exception(
      (result?.errors.isNotEmpty ?? false)
          ? result!.errors.first.errorMessage
          : 'Update event failed',
    );
  }

  Future<Map<String, dynamic>> deleteEvent({
    String? calendarId,
    required String eventId,
  }) async {
    final calendar = await _resolveCalendarId(calendarId);
    final result = await _plugin.deleteEvent(calendar, eventId);
    if (result.isSuccess) {
      return {
        'calendar_id': calendar,
        'event_id': eventId,
        'deleted': result.data ?? false,
      };
    }
    throw Exception(
      result.errors.isNotEmpty
          ? result.errors.first.errorMessage
          : 'Delete event failed',
    );
  }

  RetrieveEventsParams _buildRetrieveParams({
    String? eventId,
    String? startTime,
    String? endTime,
  }) {
    final normalizedEventId = _normalizedId(eventId);
    if (normalizedEventId != null) {
      return RetrieveEventsParams(eventIds: [normalizedEventId]);
    }

    final now = TZDateTime.now(local);
    final start = _parseDate(
      startTime ??
          TZDateTime(
            now.location,
            now.year,
            now.month,
            now.day,
          ).toIso8601String(),
      'startTime',
    );
    final end = _parseDate(
      endTime ?? start.add(const Duration(days: 30)).toIso8601String(),
      'endTime',
    );
    if (end.isBefore(start)) {
      throw ArgumentError('startTime must be before endTime');
    }
    return RetrieveEventsParams(
      startDate: start,
      endDate: end,
    );
  }

  List<Event> _filterAndSortEvents(
    List<Event> events, {
    String? searchQuery,
    bool includeAllDay = true,
  }) {
    final query = searchQuery?.trim().toLowerCase();
    final filtered = events.where((event) {
      if (!includeAllDay && (event.allDay ?? false)) return false;
      if (query == null || query.isEmpty) return true;
      final haystack = <String>[
        event.title ?? '',
        event.description ?? '',
        event.location ?? '',
      ].map((value) => value.toLowerCase());
      return haystack.any((value) => value.contains(query));
    }).toList();

    filtered.sort((a, b) {
      final aStart = a.start ?? a.end ?? TZDateTime.now(local);
      final bStart = b.start ?? b.end ?? TZDateTime.now(local);
      return aStart.compareTo(bStart);
    });

    return filtered;
  }

  int _normalizeLimit(int? maxResults) {
    if (maxResults == null) return 20;
    if (maxResults < 1) return 1;
    if (maxResults > 100) return 100;
    return maxResults;
  }

  Map<String, dynamic> _eventPayload(String calendarId, Event event) => {
    'calendar_id': calendarId,
    'event_id': event.eventId,
    'event': _eventToJson(event, calendarId: calendarId),
  };

  Map<String, dynamic> _eventToJson(
    Event event, {
    String? calendarId,
  }) => {
    'event_id': event.eventId,
    'calendar_id': calendarId ?? event.calendarId,
    'title': event.title,
    'description': event.description,
    'start': event.start?.toIso8601String(),
    'end': event.end?.toIso8601String(),
    'all_day': event.allDay ?? false,
    'availability': event.availability.name,
    'status': event.status?.name,
    'location': event.location,
    'url': event.url?.toString(),
    'is_recurring': event.recurrenceRule != null,
    'attendees': _attendeesToJson(event.attendees),
  };

  List<Map<String, dynamic>> _attendeesToJson(
    List<Attendee?>? attendees,
  ) {
    if (attendees == null) return const [];
    return attendees
        .whereType<Attendee>()
        .map(
          (attendee) => {
            'name': attendee.name,
            'email': attendee.emailAddress,
            'role': attendee.role?.name,
            'is_organizer': attendee.isOrganiser,
            'is_self': attendee.isCurrentUser,
          },
        )
        .toList();
  }

  Future<Event> _loadEvent(String calendarId, String eventId) async {
    final response = await _plugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(eventIds: [eventId]),
    );
    if (response.isSuccess &&
        response.data != null &&
        response.data!.isNotEmpty) {
      return response.data!.first;
    }
    throw Exception('Event not found');
  }

  Future<String> _resolveCalendarId(String? calendarId) async {
    await _ensurePermissions();
    final trimmed = calendarId?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;

    if (_cachedCalendarId != null) return _cachedCalendarId!;
    final calendarsResult = await _plugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      throw Exception('Unable to retrieve calendars');
    }
    final firstWritable = calendarsResult.data!.firstWhere(
      (cal) => !(cal.isReadOnly ?? true),
      orElse: () => calendarsResult.data!.first,
    );
    _cachedCalendarId = firstWritable.id;
    if (_cachedCalendarId == null || _cachedCalendarId!.isEmpty) {
      throw Exception('No writable calendar found');
    }
    return _cachedCalendarId!;
  }

  Future<void> _ensurePermissions() async {
    final hasPerms = await _plugin.hasPermissions();
    final granted = hasPerms.isSuccess && (hasPerms.data ?? false);
    if (granted) return;

    final requested = await _plugin.requestPermissions();
    final allowed = requested.isSuccess && (requested.data ?? false);
    if (!allowed) throw Exception('Calendar permission not granted');
  }

  TZDateTime _parseDate(String value, String field) {
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      throw ArgumentError('$field must be an ISO-8601 string');
    }
    return TZDateTime.from(parsed.toUtc(), local);
  }

  String? _normalizedId(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}
