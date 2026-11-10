import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/presentation/social_feed/viewmodels/social_feed_viewmodel.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('SocialFeedViewModel Unit Tests', () {
    late MockSocialRepository mockRepo;
    late SocialFeedViewModel viewModel;

    setUp(() {
      mockRepo = MockSocialRepository();
      viewModel = SocialFeedViewModel(repository: mockRepo);
    });

    test('Initializes with posts and stories', () async {
      await viewModel.loadData();
      expect(viewModel.posts.isNotEmpty, isTrue);
      expect(viewModel.stories.isNotEmpty, isTrue);
    });

    test('toggleLike updates like status and increment counter immediately on first tap', () async {
      await viewModel.loadData();
      final post = viewModel.posts.first;
      final initialLikes = post.likesCount;
      expect(post.isLiked, isFalse);

      await viewModel.toggleLike(post.id);
      expect(viewModel.posts.first.isLiked, isTrue);
      expect(viewModel.posts.first.likesCount, equals(initialLikes + 1));

      // Second tap toggles back
      await viewModel.toggleLike(post.id);
      expect(viewModel.posts.first.isLiked, isFalse);
      expect(viewModel.posts.first.likesCount, equals(initialLikes));
    });

    test('repost increments sharesCount instantaneously', () async {
      await viewModel.loadData();
      final post = viewModel.posts.first;
      final initialShares = post.sharesCount;

      await viewModel.repost(post.id);
      expect(viewModel.posts.first.sharesCount, equals(initialShares + 1));
    });

    test('createPost adds new post to top of list', () async {
      await viewModel.loadData();
      final initialCount = viewModel.posts.length;

      await viewModel.createPost(
        content: 'New architectural insight on SQLite isolates.',
        codeSnippet: 'final db = await openDatabase();',
        codeLanguage: 'dart',
        tags: ['#SQLite', '#Performance'],
      );

      expect(viewModel.posts.length, equals(initialCount + 1));
      expect(viewModel.posts.first.content, contains('SQLite isolates'));
    });

    test(
      'addComment adds comment and increments post comments count',
      () async {
        await viewModel.loadData();
        final post = viewModel.posts.first;
        final initialComments = post.commentsCount;

        await viewModel.openComments(post.id);
        await viewModel.addComment(
          postId: post.id,
          content: 'Insightful perspective on selectors!',
        );

        expect(viewModel.currentComments.length, equals(2));
        expect(
          viewModel.posts.first.commentsCount,
          equals(initialComments + 1),
        );
      },
    );
  });
}
