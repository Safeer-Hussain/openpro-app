import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/presentation/job_feed/viewmodels/job_feed_viewmodel.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('JobFeedViewModel Unit Tests', () {
    late MockJobRepository mockRepo;
    late JobFeedViewModel viewModel;

    setUp(() {
      mockRepo = MockJobRepository();
      viewModel = JobFeedViewModel(repository: mockRepo);
    });

    test('Initializes with seeded jobs list', () async {
      await viewModel.loadJobs();
      expect(viewModel.jobs.length, equals(2));
      expect(viewModel.jobs.first.title, contains('Flutter'));
    });

    test('Filters jobs accurately by search query', () async {
      await viewModel.loadJobs();
      viewModel.setSearchQuery('QuantumAI');
      expect(viewModel.jobs.length, equals(1));
      expect(viewModel.jobs.first.company, equals('QuantumAI Labs'));
    });

    test('Filters jobs accurately by workplace mode', () async {
      await viewModel.loadJobs();
      viewModel.setWorkplaceFilter('Remote');
      expect(viewModel.jobs.length, equals(1));
      expect(viewModel.jobs.first.workplaceType, equals('Remote'));
    });

    test('Toggles bookmark reactively with instant state update', () async {
      await viewModel.loadJobs();
      final initialJob = viewModel.jobs.first;
      expect(initialJob.isBookmarked, isFalse);

      await viewModel.toggleBookmark(initialJob.id);
      expect(viewModel.jobs.first.isBookmarked, isTrue);

      await viewModel.toggleBookmark(initialJob.id);
      expect(viewModel.jobs.first.isBookmarked, isFalse);
    });

    test(
      'Submits 1-tap smart application and updates status to applied',
      () async {
        await viewModel.loadJobs();
        final targetJob = viewModel.jobs.first;
        expect(targetJob.isApplied, isFalse);

        final success = await viewModel.applyToJob(
          jobId: targetJob.id,
          coverNote: 'Excited to bring Flutter architecture mastery.',
          portfolioUrl: 'https://github.com/Safeer-Hussain/openpro',
        );

        expect(success, isTrue);
        expect(viewModel.jobs.first.applicationStatus, equals('applied'));
        expect(viewModel.jobs.first.isApplied, isTrue);
      },
    );
  });
}
