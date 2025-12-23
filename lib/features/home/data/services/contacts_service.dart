import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactsService {
  Future<Map<String, dynamic>> listContacts({
    String? query,
    int? maxResults,
  }) async {
    await _ensurePermissions();
    final normalizedLimit = _normalizeLimit(maxResults);
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final filtered = _filterContacts(contacts, query);
    final limited = filtered.take(normalizedLimit).map(_contactToJson).toList();
    return {
      'count': limited.length,
      'has_more': filtered.length > limited.length,
      'contacts': limited,
    };
  }

  Future<Map<String, dynamic>> searchContacts({
    required String query,
    int? maxResults,
  }) async {
    await _ensurePermissions();
    final normalizedLimit = _normalizeLimit(maxResults);
    final contacts = await FlutterContacts.getContacts(withProperties: true);
    final filtered = _filterContacts(contacts, query);
    final limited = filtered.take(normalizedLimit).map(_contactToJson).toList();
    return {
      'count': limited.length,
      'has_more': filtered.length > limited.length,
      'contacts': limited,
    };
  }

  Future<Map<String, dynamic>> createContact({
    required String givenName,
    String? familyName,
    String? phoneNumber,
    String? email,
    String? note,
  }) async {
    await _ensurePermissions();
    final contact = Contact(
      name: Name(first: givenName.trim(), last: familyName?.trim() ?? ''),
      phones: _phonesFrom(phoneNumber),
      emails: _emailsFrom(email),
      notes: note != null && note.trim().isNotEmpty ? [Note(note.trim())] : [],
    );
    await contact.insert();
    return _contactPayload('created', contact);
  }

  Future<Map<String, dynamic>> updateContact({
    required String contactId,
    String? givenName,
    String? familyName,
    String? phoneNumber,
    String? email,
    String? note,
  }) async {
    await _ensurePermissions();
    final existing = await _loadContact(contactId);
    if (givenName != null) existing.name.first = givenName.trim();
    if (familyName != null) existing.name.last = familyName.trim();
    if (phoneNumber != null) existing.phones = _phonesFrom(phoneNumber);
    if (email != null) existing.emails = _emailsFrom(email);
    if (note != null) {
      existing.notes = note.trim().isEmpty ? [] : [Note(note.trim())];
    }
    await existing.update();
    return _contactPayload('updated', existing);
  }

  Future<Map<String, dynamic>> deleteContact({
    required String contactId,
  }) async {
    await _ensurePermissions();
    final contact = Contact(id: contactId);
    await FlutterContacts.deleteContact(contact);
    return {
      'contact_id': contactId,
      'deleted': true,
    };
  }

  Future<Map<String, dynamic>> callContact({
    String? contactId,
    String? phoneNumber,
  }) async {
    final number = await _resolvePhoneNumber(
      contactId: contactId,
      phoneNumber: phoneNumber,
    );
    if (number == null) {
      throw ArgumentError('Provide phone_number or contact_id with a phone');
    }
    final uri = Uri(scheme: 'tel', path: number);
    final success = await launchUrl(uri);
    return {
      'contact_id': contactId,
      'phone_number': number,
      'called': success,
    };
  }

  Future<Map<String, dynamic>> sendSms({
    required String message,
    String? contactId,
    String? phoneNumber,
    List<String>? recipients,
  }) async {
    final resolvedRecipients = await _resolveRecipients(
      contactId: contactId,
      phoneNumber: phoneNumber,
      recipients: recipients,
    );
    if (resolvedRecipients.isEmpty) {
      throw ArgumentError(
        'Provide at least one phone number or contact with numbers',
      );
    }
    final uri = Uri(
      scheme: 'sms',
      path: resolvedRecipients.join(','),
      queryParameters: {'body': message.trim()},
    );
    final launched = await launchUrl(uri);
    return {
      'contact_id': contactId,
      'recipients': resolvedRecipients,
      'sent': launched,
    };
  }

  Future<Contact> _loadContact(String contactId) async {
    final contact = await FlutterContacts.getContact(
      contactId,
      withProperties: true,
      withPhoto: true,
      withThumbnail: true,
    );
    if (contact == null) {
      throw Exception('Contact not found');
    }
    return contact;
  }

  Future<String?> _resolvePhoneNumber({
    String? contactId,
    String? phoneNumber,
  }) async {
    final trimmed = phoneNumber?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    if (contactId == null || contactId.isEmpty) return null;
    final contact = await _loadContact(contactId);
    if (contact.phones.isEmpty) return null;
    return contact.phones.first.number;
  }

  Future<List<String>> _resolveRecipients({
    String? contactId,
    String? phoneNumber,
    List<String>? recipients,
  }) async {
    final numbers = <String>{};
    if (phoneNumber != null && phoneNumber.trim().isNotEmpty) {
      numbers.add(phoneNumber.trim());
    }
    if (recipients != null) {
      for (final r in recipients) {
        final trimmed = r.trim();
        if (trimmed.isNotEmpty) numbers.add(trimmed);
      }
    }
    if (contactId != null && contactId.isNotEmpty) {
      final contact = await _loadContact(contactId);
      for (final phone in contact.phones) {
        final num = phone.number.trim();
        if (num.isNotEmpty) numbers.add(num);
      }
    }
    return numbers.toList();
  }

  List<Contact> _filterContacts(List<Contact> contacts, String? query) {
    final trimmed = query?.trim().toLowerCase();
    if (trimmed == null || trimmed.isEmpty) return contacts;
    return contacts.where((c) {
      final haystack = <String>[
        c.displayName,
        c.name.first,
        c.name.last,
        ...c.phones.map((p) => p.number),
        ...c.emails.map((e) => e.address),
      ].map((v) => v.toLowerCase());
      return haystack.any((v) => v.contains(trimmed));
    }).toList();
  }

  Map<String, dynamic> _contactPayload(String action, Contact contact) => {
    'action': action,
    'contact': _contactToJson(contact),
  };

  Map<String, dynamic> _contactToJson(Contact contact) => {
    'contact_id': contact.id,
    'display_name': contact.displayName,
    'given_name': contact.name.first,
    'family_name': contact.name.last,
    'phones': contact.phones
        .map(
          (p) => {
            'number': p.number,
            'label': p.label.name,
            'custom_label': p.customLabel,
            'normalized_number': p.normalizedNumber,
            'is_primary': p.isPrimary,
          },
        )
        .toList(),
    'emails': contact.emails
        .map(
          (e) => {
            'address': e.address,
            'label': e.label.name,
            'custom_label': e.customLabel,
            'is_primary': e.isPrimary,
          },
        )
        .toList(),
    'notes': contact.notes.map((n) => n.note).toList(),
  };

  List<Phone> _phonesFrom(String? value) {
    if (value == null || value.trim().isEmpty) return [];
    return [Phone(value.trim())];
  }

  List<Email> _emailsFrom(String? value) {
    if (value == null || value.trim().isEmpty) return [];
    return [Email(value.trim())];
  }

  int _normalizeLimit(int? limit) {
    if (limit == null) return 50;
    if (limit < 1) return 1;
    if (limit > 200) return 200;
    return limit;
  }

  Future<void> _ensurePermissions() async {
    final granted = await FlutterContacts.requestPermission();
    if (!granted) throw Exception('Contacts permission not granted');
  }
}
