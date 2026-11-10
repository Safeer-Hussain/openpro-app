import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/core/utils/match_calculator.dart';

void main() {
  group('MatchCalculator Unit Tests', () {
    test(
      'Calculates high match score for identical skills and role titles',
      () {
        final score = MatchCalculator.calculateScore(
          candidateSkills: [
            'Flutter',
            'Dart',
            'Provider',
            'SQLite',
            'Clean Architecture',
          ],
          candidateTitle: 'Senior Flutter Architect',
          jobSkills: ['Flutter', 'Dart', 'Provider', 'SQLite'],
          jobTitle: 'Principal Flutter Architect',
          workplaceType: 'Remote',
        );

        expect(score, greaterThanOrEqualTo(90));
        expect(score, lessThanOrEqualTo(98));
      },
    );

    test('Calculates lower score when skills have low overlap', () {
      final score = MatchCalculator.calculateScore(
        candidateSkills: ['Python', 'Django', 'PostgreSQL'],
        candidateTitle: 'Backend Python Engineer',
        jobSkills: ['Flutter', 'Dart', 'Swift', 'Kotlin'],
        jobTitle: 'Mobile Team Lead',
        workplaceType: 'On-Site',
      );

      expect(score, lessThan(65));
    });

    test('Clamps score between baseline 45 and maximum 98', () {
      final emptyScore = MatchCalculator.calculateScore(
        candidateSkills: [],
        candidateTitle: '',
        jobSkills: ['Rust', 'Wasm'],
        jobTitle: 'Kernel Systems Developer',
        workplaceType: 'On-Site',
      );

      expect(emptyScore, greaterThanOrEqualTo(45));
    });
  });
}
