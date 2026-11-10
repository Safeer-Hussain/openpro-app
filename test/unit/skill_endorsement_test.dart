import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/domain/entities/skill_endorsement.dart';
import 'package:open_pro/presentation/profile/viewmodels/profile_viewmodel.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('SkillEndorsement and Repository Unit Tests', () {
    late MockProfileRepository mockProfileRepo;
    late MockSkillRepository mockSkillRepo;
    late ProfileViewModel viewModel;

    setUp(() {
      mockProfileRepo = MockProfileRepository();
      mockSkillRepo = MockSkillRepository();
      viewModel = ProfileViewModel(
        repository: mockProfileRepo,
        skillRepository: mockSkillRepo,
      );
    });

    test('SkillEndorsement entity supports copyWith and immutability', () {
      const original = SkillEndorsement(
        skillName: 'Dart Concurrency',
        count: 5,
        isEndorsedByMe: false,
        topEndorsers: [
          Endorser(
            id: 'end_1',
            name: 'Alex Rivera',
            title: 'Staff Architect',
            avatarUrl: 'assets/images/techcorp.png',
          ),
        ],
      );

      final updated = original.copyWith(count: 6, isEndorsedByMe: true);

      expect(updated.skillName, equals('Dart Concurrency'));
      expect(updated.count, equals(6));
      expect(updated.isEndorsedByMe, isTrue);
      expect(original.count, equals(5));
      expect(original.isEndorsedByMe, isFalse);
    });

    test('Loads peer skill endorsements for target profile', () async {
      await viewModel.loadProfile();

      expect(viewModel.endorsements, isNotEmpty);
      expect(
        viewModel.endorsements.first.skillName,
        equals('Flutter & Dart Architecture'),
      );
      expect(viewModel.endorsements.first.count, equals(3));
      expect(viewModel.endorsements.first.isEndorsedByMe, isFalse);
      expect(viewModel.endorsements.first.topEndorsers.length, equals(3));
    });

    test('toggleEndorsement increments count and updates isEndorsedByMe instantaneously', () async {
      await viewModel.loadProfile();

      final initialSkill = viewModel.endorsements.firstWhere(
        (e) => e.skillName == 'Flutter & Dart Architecture',
      );
      expect(initialSkill.isEndorsedByMe, isFalse);
      final initialCount = initialSkill.count;

      bool listenerNotified = false;
      viewModel.addListener(() {
        listenerNotified = true;
      });

      await viewModel.toggleEndorsement('Flutter & Dart Architecture');

      expect(listenerNotified, isTrue);
      final updatedSkill = viewModel.endorsements.firstWhere(
        (e) => e.skillName == 'Flutter & Dart Architecture',
      );
      expect(updatedSkill.isEndorsedByMe, isTrue);
      expect(updatedSkill.count, equals(initialCount + 1));
      expect(updatedSkill.topEndorsers.any((e) => e.name == 'You'), isTrue);
    });

    test(
      'toggleEndorsement twice toggles state back and decrements count',
      () async {
        await viewModel.loadProfile();

        final initialCount = viewModel.endorsements.first.count;

        // First toggle: endorse
        await viewModel.toggleEndorsement('Flutter & Dart Architecture');
        expect(viewModel.endorsements.first.isEndorsedByMe, isTrue);
        expect(viewModel.endorsements.first.count, equals(initialCount + 1));

        // Second toggle: un-endorse
        await viewModel.toggleEndorsement('Flutter & Dart Architecture');
        expect(viewModel.endorsements.first.isEndorsedByMe, isFalse);
        expect(viewModel.endorsements.first.count, equals(initialCount));
        expect(
          viewModel.endorsements.first.topEndorsers.any((e) => e.name == 'You'),
          isFalse,
        );
      },
    );
  });
}
