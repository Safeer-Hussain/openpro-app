import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/presentation/profile/viewmodels/profile_viewmodel.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('ProfileViewModel Unit Tests', () {
    late MockProfileRepository mockRepo;
    late ProfileViewModel viewModel;

    setUp(() {
      mockRepo = MockProfileRepository();
      viewModel = ProfileViewModel(repository: mockRepo);
    });

    test('Initializes with seeded Safeer Hussain profile', () async {
      await viewModel.loadProfile();
      expect(viewModel.profile, isNotNull);
      expect(viewModel.profile!.name, equals('Safeer Hussain'));
      expect(viewModel.profile!.isOpenToWork, isTrue);
    });

    test('toggleOpenToWork mutates status reactively', () async {
      await viewModel.loadProfile();
      expect(viewModel.profile!.isOpenToWork, isTrue);

      await viewModel.toggleOpenToWork();
      expect(viewModel.profile!.isOpenToWork, isFalse);

      await viewModel.toggleOpenToWork();
      expect(viewModel.profile!.isOpenToWork, isTrue);
    });

    test('updateBioAndTitle updates profile headline and bio', () async {
      await viewModel.loadProfile();

      await viewModel.updateBioAndTitle(
        name: 'Safeer Hussain',
        title: 'VP of Mobile Engineering',
        company: 'Global Tech Systems',
        location: 'Remote',
        bio: 'Executive leader scaling high-velocity mobile orgs.',
        skills: ['Flutter', 'Systems Design'],
      );

      expect(viewModel.profile!.title, equals('VP of Mobile Engineering'));
      expect(viewModel.profile!.company, equals('Global Tech Systems'));
    });

    test(
      'addExperience inserts new role to start of experiences list',
      () async {
        await viewModel.loadProfile();
        final initialCount = viewModel.profile!.experiences.length;

        await viewModel.addExperience(
          role: 'Chief Architect',
          company: 'NextGen AI Mobility',
          location: 'Austin, TX',
          startDate: '2024',
          endDate: 'Present',
          isCurrent: true,
          description: 'Pioneered on-device intelligence architecture.',
        );

        expect(viewModel.profile!.experiences.length, equals(initialCount + 1));
        expect(
          viewModel.profile!.experiences.first.role,
          equals('Chief Architect'),
        );
      },
    );
  });
}
