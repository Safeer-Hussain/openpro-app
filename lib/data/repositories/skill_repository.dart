import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_tables.dart';
import '../../domain/entities/skill_endorsement.dart';
import '../../domain/repositories/skill_repository_interface.dart';

class SkillRepository implements SkillRepositoryInterface {
  final AppDatabase database;

  SkillRepository({required this.database});

  @override
  Future<List<SkillEndorsement>> getEndorsementsForUser([
    String userId = AppConstants.defaultUserId,
  ]) async {
    final db = await database.database;
    final rows = await db.query(
      DatabaseTables.skillEndorsements,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final row in rows) {
      final skill = row['skill_name'] as String;
      grouped.putIfAbsent(skill, () => []).add(row);
    }

    final List<SkillEndorsement> result = [];
    for (final entry in grouped.entries) {
      final skill = entry.key;
      final skillRows = entry.value;

      final isEndorsedByMe = skillRows.any(
        (r) => (r['is_endorsed_by_me'] as int? ?? 0) == 1,
      );
      final endorsers = skillRows.map((r) {
        return Endorser(
          id: r['id'] as String,
          name: r['endorser_name'] as String,
          title: r['endorser_title'] as String,
          avatarUrl: r['endorser_avatar'] as String,
        );
      }).toList();

      result.add(
        SkillEndorsement(
          skillName: skill,
          count: skillRows.length,
          isEndorsedByMe: isEndorsedByMe,
          topEndorsers: endorsers,
        ),
      );
    }

    // Sort by endorsement count descending
    result.sort((a, b) => b.count.compareTo(a.count));
    return result;
  }

  @override
  Future<SkillEndorsement> toggleEndorsement({
    required String userId,
    required String skillName,
    required String endorserName,
    required String endorserTitle,
    required String endorserAvatar,
  }) async {
    final db = await database.database;

    final existing = await db.query(
      DatabaseTables.skillEndorsements,
      where: 'user_id = ? AND skill_name = ? AND is_endorsed_by_me = 1',
      whereArgs: [userId, skillName],
    );

    if (existing.isNotEmpty) {
      await db.delete(
        DatabaseTables.skillEndorsements,
        where: 'user_id = ? AND skill_name = ? AND is_endorsed_by_me = 1',
        whereArgs: [userId, skillName],
      );
    } else {
      await db.insert(DatabaseTables.skillEndorsements, {
        'id': 'end_me_${DateTime.now().millisecondsSinceEpoch}',
        'user_id': userId,
        'skill_name': skillName,
        'endorser_name': endorserName,
        'endorser_title': endorserTitle,
        'endorser_avatar': endorserAvatar,
        'created_at': 'Just now',
        'is_endorsed_by_me': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    final allForSkill = await db.query(
      DatabaseTables.skillEndorsements,
      where: 'user_id = ? AND skill_name = ?',
      whereArgs: [userId, skillName],
    );

    final isEndorsed = allForSkill.any(
      (r) => (r['is_endorsed_by_me'] as int? ?? 0) == 1,
    );
    final endorsers = allForSkill.map((r) {
      return Endorser(
        id: r['id'] as String,
        name: r['endorser_name'] as String,
        title: r['endorser_title'] as String,
        avatarUrl: r['endorser_avatar'] as String,
      );
    }).toList();

    return SkillEndorsement(
      skillName: skillName,
      count: allForSkill.length,
      isEndorsedByMe: isEndorsed,
      topEndorsers: endorsers,
    );
  }
}
