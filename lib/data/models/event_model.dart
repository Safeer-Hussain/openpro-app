import 'dart:convert';

import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    required super.organizer,
    required super.organizerLogo,
    required super.dateDescription,
    required super.dateTime,
    required super.locationOrLink,
    required super.isVirtual,
    required super.attendeeCount,
    required super.isRsvp,
    required super.speakers,
    required super.tags,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(val.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      organizer: map['organizer'] as String,
      organizerLogo: map['organizer_logo'] as String,
      dateDescription: map['date_description'] as String,
      dateTime: map['date_time'] as String,
      locationOrLink: map['location_or_link'] as String,
      isVirtual: (map['is_virtual'] as num?)?.toInt() == 1,
      attendeeCount: (map['attendee_count'] as num?)?.toInt() ?? 0,
      isRsvp: (map['is_rsvp'] as num?)?.toInt() == 1,
      speakers: parseList(map['speakers']),
      tags: parseList(map['tags']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'organizer': organizer,
      'organizer_logo': organizerLogo,
      'date_description': dateDescription,
      'date_time': dateTime,
      'location_or_link': locationOrLink,
      'is_virtual': isVirtual ? 1 : 0,
      'attendee_count': attendeeCount,
      'is_rsvp': isRsvp ? 1 : 0,
      'speakers': jsonEncode(speakers),
      'tags': jsonEncode(tags),
    };
  }
}
