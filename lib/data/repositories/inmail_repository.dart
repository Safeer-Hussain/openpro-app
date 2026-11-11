import '../../core/constants/app_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_tables.dart';
import '../../domain/entities/inmail_message.dart';
import '../../domain/repositories/inmail_repository_interface.dart';

class InmailRepository implements InmailRepositoryInterface {
  final AppDatabase database;

  InmailRepository({required this.database});

  @override
  Future<List<InmailMessage>> getMessages({
    String? category,
    String? userId = AppConstants.defaultUserId,
  }) async {
    final db = await database.database;
    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (userId != null && userId.isNotEmpty) {
      whereClauses.add('user_id = ?');
      whereArgs.add(userId);
    }

    if (category != null && category.isNotEmpty) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final results = await db.query(
      DatabaseTables.inmailMessages,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: "CASE WHEN status = 'unread' THEN 0 WHEN status = 'read' THEN 1 ELSE 2 END, id DESC",
    );

    return results.map((map) => InmailMessage.fromMap(map)).toList();
  }

  @override
  Future<InmailMessage?> getMessageById(String id) async {
    final db = await database.database;
    final results = await db.query(
      DatabaseTables.inmailMessages,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return InmailMessage.fromMap(results.first);
  }

  @override
  Future<void> markAsRead(String id) async {
    final db = await database.database;
    await db.update(
      DatabaseTables.inmailMessages,
      {'status': 'read'},
      where: "id = ? AND status = 'unread'",
      whereArgs: [id],
    );
  }

  @override
  Future<InmailMessage> sendReply({
    required String id,
    required String replyContent,
  }) async {
    final db = await database.database;
    final now = DateTime.now();
    final repliedAtFormatted =
        'Just now (${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')})';

    await db.update(
      DatabaseTables.inmailMessages,
      {
        'status': 'replied',
        'reply_content': replyContent,
        'replied_at': repliedAtFormatted,
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    final updated = await getMessageById(id);
    if (updated != null) {
      return updated;
    }

    throw StateError('InMail message with id $id not found after update');
  }

  @override
  Future<int> getUnreadCount({
    String? category,
    String? userId = AppConstants.defaultUserId,
  }) async {
    final db = await database.database;
    final whereClauses = ["status = 'unread'"];
    final whereArgs = <dynamic>[];

    if (userId != null && userId.isNotEmpty) {
      whereClauses.add('user_id = ?');
      whereArgs.add(userId);
    }

    if (category != null && category.isNotEmpty) {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.inmailMessages} WHERE ${whereClauses.join(' AND ')}',
      whereArgs,
    );

    if (result.isNotEmpty) {
      return (result.first['count'] as int?) ?? 0;
    }
    return 0;
  }
}
