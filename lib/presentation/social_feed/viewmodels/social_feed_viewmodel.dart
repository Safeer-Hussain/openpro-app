import 'package:flutter/foundation.dart';

import '../../../data/repositories/social_repository.dart';
import '../../../domain/entities/comment_entity.dart';
import '../../../domain/entities/post_entity.dart';
import '../../../domain/entities/story_entity.dart';

class SocialFeedViewModel extends ChangeNotifier {
  final SocialRepository repository;

  List<PostEntity> _posts = [];
  List<StoryEntity> _stories = [];
  bool _isLoading = true;
  String? _activePostCommentsId;
  List<CommentEntity> _currentComments = [];
  bool _isLoadingComments = false;

  SocialFeedViewModel({required this.repository}) {
    loadData();
  }

  List<PostEntity> get posts => _posts;
  List<StoryEntity> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get activePostCommentsId => _activePostCommentsId;
  List<CommentEntity> get currentComments => _currentComments;
  bool get isLoadingComments => _isLoadingComments;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        repository.getPosts(),
        repository.getStories(),
      ]);
      _posts = results[0] as List<PostEntity>;
      _stories = results[1] as List<StoryEntity>;
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final current = _posts[index];
    final willBeLiked = !current.isLiked;
    final newCount = willBeLiked
        ? current.likesCount + 1
        : (current.likesCount - 1).clamp(0, 999999);

    final updated = current.copyWith(
      isLiked: willBeLiked,
      likesCount: newCount,
    );

    // Optimistic immediate mutation
    _posts[index] = updated;
    notifyListeners();

    try {
      await repository.toggleLike(postId);
    } catch (_) {
      // Revert if database write fails
      _posts[index] = current;
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final current = _posts[index];
    final updated = current.copyWith(isBookmarked: !current.isBookmarked);

    _posts[index] = updated;
    notifyListeners();

    try {
      await repository.toggleBookmark(postId);
    } catch (_) {
      _posts[index] = current;
      notifyListeners();
    }
  }

  Future<void> repost(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final current = _posts[index];
    final updated = current.copyWith(sharesCount: current.sharesCount + 1);

    _posts[index] = updated;
    notifyListeners();

    try {
      await repository.repost(postId);
    } catch (_) {
      _posts[index] = current;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String content,
    String? codeSnippet,
    String? codeLanguage,
    List<String> tags = const [],
  }) async {
    final newPost = PostEntity(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Safeer Hussain',
      authorRole: 'Senior Flutter Architect',
      authorAvatar: 'assets/images/safeer_avatar.png',
      authorCompany: 'OpenPro Labs',
      content: content,
      codeSnippet: codeSnippet,
      codeLanguage: codeLanguage,
      timestamp: 'Just now',
      likesCount: 0,
      commentsCount: 0,
      sharesCount: 0,
      isLiked: false,
      isBookmarked: false,
      tags: tags,
    );

    _posts.insert(0, newPost);
    notifyListeners();

    try {
      await repository.createPost(newPost);
    } catch (_) {}
  }

  Future<void> openComments(String postId) async {
    _activePostCommentsId = postId;
    _isLoadingComments = true;
    _currentComments = [];
    notifyListeners();

    try {
      _currentComments = await repository.getComments(postId);
    } catch (_) {}
    _isLoadingComments = false;
    notifyListeners();
  }

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final newComment = CommentEntity(
      id: 'com_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorName: 'Safeer Hussain',
      authorAvatar: 'assets/images/safeer_avatar.png',
      authorRole: 'Senior Flutter Architect',
      content: content,
      timestamp: 'Just now',
    );

    _currentComments.add(newComment);

    // Update post comments_count in memory
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final p = _posts[postIndex];
      _posts[postIndex] = p.copyWith(commentsCount: p.commentsCount + 1);
    }
    notifyListeners();

    try {
      await repository.addComment(newComment);
    } catch (_) {}
  }

  Future<void> deleteComment(String commentId, String postId) async {
    _currentComments.removeWhere((c) => c.id == commentId);

    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final p = _posts[postIndex];
      final newCount = (p.commentsCount - 1).clamp(0, 999999);
      _posts[postIndex] = p.copyWith(commentsCount: newCount);
    }
    notifyListeners();

    try {
      await repository.deleteComment(commentId, postId);
    } catch (_) {}
  }

  Future<void> createStory({
    required String title,
    required String subtitle,
    required String mediaUrl,
  }) async {
    final newStory = StoryEntity(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}',
      authorName: 'Safeer Hussain',
      authorAvatar: 'assets/images/safeer_avatar.png',
      title: title,
      subtitle: subtitle,
      mediaUrl: mediaUrl,
      durationSeconds: 6,
      postedAt: 'Just now',
      isViewed: false,
      reactionCount: 0,
    );

    _stories.insert(0, newStory);
    notifyListeners();

    try {
      await repository.createStory(newStory);
    } catch (_) {}
  }

  Future<void> reactToStory(String storyId) async {
    final index = _stories.indexWhere((s) => s.id == storyId);
    if (index == -1) return;

    final current = _stories[index];
    _stories[index] = current.copyWith(
      reactionCount: current.reactionCount + 1,
    );
    notifyListeners();

    try {
      await repository.reactToStory(storyId);
    } catch (_) {}
  }
}
