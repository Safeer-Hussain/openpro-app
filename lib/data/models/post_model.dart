import 'dart:convert';

import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.authorName,
    required super.authorRole,
    required super.authorAvatar,
    required super.authorCompany,
    required super.content,
    super.codeSnippet,
    super.codeLanguage,
    required super.timestamp,
    required super.likesCount,
    required super.commentsCount,
    required super.sharesCount,
    required super.isLiked,
    required super.isBookmarked,
    required super.tags,
    super.imageUrl,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(val.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return PostModel(
      id: map['id'] as String,
      authorName: map['author_name'] as String,
      authorRole: map['author_role'] as String,
      authorAvatar: map['author_avatar'] as String,
      authorCompany: map['author_company'] as String,
      content: map['content'] as String,
      codeSnippet: map['code_snippet'] as String?,
      codeLanguage: map['code_language'] as String?,
      timestamp: map['timestamp'] as String,
      likesCount: (map['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (map['comments_count'] as num?)?.toInt() ?? 0,
      sharesCount: (map['shares_count'] as num?)?.toInt() ?? 0,
      isLiked: (map['is_liked'] as num?)?.toInt() == 1,
      isBookmarked: (map['is_bookmarked'] as num?)?.toInt() == 1,
      tags: parseList(map['tags']),
      imageUrl: map['image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author_name': authorName,
      'author_role': authorRole,
      'author_avatar': authorAvatar,
      'author_company': authorCompany,
      'content': content,
      'code_snippet': codeSnippet,
      'code_language': codeLanguage,
      'timestamp': timestamp,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'is_liked': isLiked ? 1 : 0,
      'is_bookmarked': isBookmarked ? 1 : 0,
      'tags': jsonEncode(tags),
      'image_url': imageUrl,
    };
  }
}
