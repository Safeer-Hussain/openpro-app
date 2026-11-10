import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_tables.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/story_entity.dart';
import '../models/comment_model.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';

class SocialRepository {
  final AppDatabase database;

  SocialRepository({required this.database});

  Future<List<PostEntity>> getPosts() async {
    final db = await database.database;
    final maps = await db.query(DatabaseTables.posts, orderBy: 'rowid DESC');
    return maps.map((m) => PostModel.fromMap(m)).toList();
  }

  Future<void> createPost(PostEntity post) async {
    final db = await database.database;
    final model = PostModel(
      id: post.id,
      authorName: post.authorName,
      authorRole: post.authorRole,
      authorAvatar: post.authorAvatar,
      authorCompany: post.authorCompany,
      content: post.content,
      codeSnippet: post.codeSnippet,
      codeLanguage: post.codeLanguage,
      timestamp: post.timestamp,
      likesCount: post.likesCount,
      commentsCount: post.commentsCount,
      sharesCount: post.sharesCount,
      isLiked: post.isLiked,
      isBookmarked: post.isBookmarked,
      tags: post.tags,
      imageUrl: post.imageUrl,
    );
    await db.insert(
      DatabaseTables.posts,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<PostEntity?> toggleLike(String postId) async {
    final db = await database.database;
    final results = await db.query(
      DatabaseTables.posts,
      where: 'id = ?',
      whereArgs: [postId],
      limit: 1,
    );
    if (results.isEmpty) return null;

    final current = PostModel.fromMap(results.first);
    final willBeLiked = !current.isLiked;
    final newCount = willBeLiked
        ? current.likesCount + 1
        : (current.likesCount - 1).clamp(0, 999999);

    await db.update(
      DatabaseTables.posts,
      {'is_liked': willBeLiked ? 1 : 0, 'likes_count': newCount},
      where: 'id = ?',
      whereArgs: [postId],
    );

    return current.copyWith(isLiked: willBeLiked, likesCount: newCount);
  }

  Future<PostEntity?> toggleBookmark(String postId) async {
    final db = await database.database;
    final results = await db.query(
      DatabaseTables.posts,
      where: 'id = ?',
      whereArgs: [postId],
      limit: 1,
    );
    if (results.isEmpty) return null;

    final current = PostModel.fromMap(results.first);
    final willBeSaved = !current.isBookmarked;

    await db.update(
      DatabaseTables.posts,
      {'is_bookmarked': willBeSaved ? 1 : 0},
      where: 'id = ?',
      whereArgs: [postId],
    );

    return current.copyWith(isBookmarked: willBeSaved);
  }

  Future<PostEntity?> repost(String postId) async {
    final db = await database.database;
    final results = await db.query(
      DatabaseTables.posts,
      where: 'id = ?',
      whereArgs: [postId],
      limit: 1,
    );
    if (results.isEmpty) return null;

    final current = PostModel.fromMap(results.first);
    final newShares = current.sharesCount + 1;

    await db.update(
      DatabaseTables.posts,
      {'shares_count': newShares},
      where: 'id = ?',
      whereArgs: [postId],
    );

    return current.copyWith(sharesCount: newShares);
  }

  Future<List<CommentEntity>> getComments(String postId) async {
    final db = await database.database;
    final maps = await db.query(
      DatabaseTables.comments,
      where: 'post_id = ?',
      whereArgs: [postId],
      orderBy: 'rowid ASC',
    );
    return maps.map((m) => CommentModel.fromMap(m)).toList();
  }

  Future<void> addComment(CommentEntity comment) async {
    final db = await database.database;
    final model = CommentModel(
      id: comment.id,
      postId: comment.postId,
      authorName: comment.authorName,
      authorAvatar: comment.authorAvatar,
      authorRole: comment.authorRole,
      content: comment.content,
      timestamp: comment.timestamp,
    );
    await db.insert(DatabaseTables.comments, model.toMap());

    // Increment post comments_count
    await db.rawUpdate(
      '''
      UPDATE ${DatabaseTables.posts}
      SET comments_count = comments_count + 1
      WHERE id = ?
    ''',
      [comment.postId],
    );
  }

  Future<void> deleteComment(String commentId, String postId) async {
    final db = await database.database;
    await db.delete(
      DatabaseTables.comments,
      where: 'id = ?',
      whereArgs: [commentId],
    );

    // Decrement post comments_count
    await db.rawUpdate(
      '''
      UPDATE ${DatabaseTables.posts}
      SET comments_count = CASE WHEN comments_count > 0 THEN comments_count - 1 ELSE 0 END
      WHERE id = ?
    ''',
      [postId],
    );
  }

  Future<List<StoryEntity>> getStories() async {
    final db = await database.database;
    final maps = await db.query(DatabaseTables.stories);
    return maps.map((m) => StoryModel.fromMap(m)).toList();
  }

  Future<void> createStory(StoryEntity story) async {
    final db = await database.database;
    final model = StoryModel(
      id: story.id,
      authorName: story.authorName,
      authorAvatar: story.authorAvatar,
      title: story.title,
      subtitle: story.subtitle,
      mediaUrl: story.mediaUrl,
      durationSeconds: story.durationSeconds,
      postedAt: story.postedAt,
      isViewed: story.isViewed,
      reactionCount: story.reactionCount,
    );
    await db.insert(
      DatabaseTables.stories,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markStoryViewed(String storyId) async {
    final db = await database.database;
    await db.update(
      DatabaseTables.stories,
      {'is_viewed': 1},
      where: 'id = ?',
      whereArgs: [storyId],
    );
  }

  Future<void> reactToStory(String storyId) async {
    final db = await database.database;
    await db.rawUpdate(
      '''
      UPDATE ${DatabaseTables.stories}
      SET reaction_count = reaction_count + 1
      WHERE id = ?
    ''',
      [storyId],
    );
  }
}
