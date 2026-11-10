import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_tables.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../models/event_model.dart';
import '../models/group_model.dart';

class CommunityRepository {
  final AppDatabase database;

  CommunityRepository({required this.database});

  Future<List<GroupEntity>> getGroups() async {
    final db = await database.database;
    final maps = await db.query(DatabaseTables.groups);
    return maps.map((m) => GroupModel.fromMap(m)).toList();
  }

  Future<GroupEntity?> toggleJoinGroup(String groupId) async {
    final db = await database.database;
    final results = await db.query(
      DatabaseTables.groups,
      where: 'id = ?',
      whereArgs: [groupId],
      limit: 1,
    );
    if (results.isEmpty) return null;

    final current = GroupModel.fromMap(results.first);
    final willJoin = !current.isJoined;
    final newCount = willJoin
        ? current.memberCount + 1
        : (current.memberCount - 1).clamp(0, 999999);

    await db.update(
      DatabaseTables.groups,
      {'is_joined': willJoin ? 1 : 0, 'member_count': newCount},
      where: 'id = ?',
      whereArgs: [groupId],
    );

    return current.copyWith(isJoined: willJoin, memberCount: newCount);
  }

  Future<List<EventEntity>> getEvents() async {
    final db = await database.database;
    final maps = await db.query(DatabaseTables.events);
    return maps.map((m) => EventModel.fromMap(m)).toList();
  }

  Future<EventEntity?> toggleRsvpEvent(String eventId) async {
    final db = await database.database;
    final results = await db.query(
      DatabaseTables.events,
      where: 'id = ?',
      whereArgs: [eventId],
      limit: 1,
    );
    if (results.isEmpty) return null;

    final current = EventModel.fromMap(results.first);
    final willRsvp = !current.isRsvp;
    final newCount = willRsvp
        ? current.attendeeCount + 1
        : (current.attendeeCount - 1).clamp(0, 999999);

    await db.update(
      DatabaseTables.events,
      {'is_rsvp': willRsvp ? 1 : 0, 'attendee_count': newCount},
      where: 'id = ?',
      whereArgs: [eventId],
    );

    return current.copyWith(isRsvp: willRsvp, attendeeCount: newCount);
  }

  Future<void> createEvent(EventEntity event) async {
    final db = await database.database;
    final model = EventModel(
      id: event.id,
      title: event.title,
      organizer: event.organizer,
      organizerLogo: event.organizerLogo,
      dateDescription: event.dateDescription,
      dateTime: event.dateTime,
      locationOrLink: event.locationOrLink,
      isVirtual: event.isVirtual,
      attendeeCount: event.attendeeCount,
      isRsvp: event.isRsvp,
      speakers: event.speakers,
      tags: event.tags,
    );
    await db.insert(
      DatabaseTables.events,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
