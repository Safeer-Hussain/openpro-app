import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/domain/calculators/salary_percentile_calculator.dart';

void main() {
  group('SalaryPercentileCalculator Unit Tests', () {
    test(
      'Calculates base benchmarks for Junior seniority with neutral multiplier',
      () {
        final benchmark = SalaryPercentileCalculator.calculate(
          seniority: 'junior',
          role: 'General Engineer',
          location: 'Remote',
          candidateSalary: 105000,
        );

        expect(benchmark.p25, equals(85000));
        expect(benchmark.p50, equals(105000));
        expect(benchmark.p75, equals(125000));
        expect(benchmark.p90, equals(145000));
        expect(benchmark.percentile, closeTo(50.0, 0.1));
        expect(benchmark.tier, equals('Market Competitive'));
        expect(benchmark.formattedPercentile, equals('50th Percentile'));
      },
    );

    test(
      'Computes Senior benchmarks and interpolates top quartile compensation',
      () {
        final benchmark = SalaryPercentileCalculator.calculate(
          seniority: 'senior',
          role: 'General Engineer',
          location: 'Remote',
          candidateSalary: 200000,
        );

        expect(benchmark.p25, equals(155000));
        expect(benchmark.p50, equals(185000));
        expect(benchmark.p75, equals(215000));
        expect(benchmark.p90, equals(245000));
        expect(benchmark.percentile, greaterThan(50.0));
        expect(benchmark.percentile, lessThan(75.0));
        expect(benchmark.tier, equals('Market Competitive'));
      },
    );

    test(
      'Applies AI/ML role multiplier and SF location premium for Principal',
      () {
        final benchmark = SalaryPercentileCalculator.calculate(
          seniority: 'principal',
          role: 'Staff AI/ML Architect',
          location: 'San Francisco, CA',
          candidateSalary: 450000,
        );

        // AI/ML mult: 1.15, SF mult: 1.20 => combined = 1.38
        // p50 is ~365k, p75 is ~427k, p90 is ~496k. So 450k is in Top Quartile (~80th percentile)
        expect(benchmark.p50, closeTo(265000 * 1.38, 10.0));
        expect(benchmark.percentile, greaterThanOrEqualTo(75.0));
        expect(benchmark.tier, equals('Top Quartile'));
      },
    );

    test('Clamps extreme low salaries to bottom boundary without failure', () {
      final benchmark = SalaryPercentileCalculator.calculate(
        seniority: 'junior',
        role: 'Intern',
        location: 'Remote',
        candidateSalary: 20000,
      );

      expect(benchmark.percentile, equals(5.0));
      expect(benchmark.tier, equals('Entry / Standard Tier'));
    });

    test('Clamps extreme high salaries to 99th percentile boundary', () {
      final benchmark = SalaryPercentileCalculator.calculate(
        seniority: 'lead',
        role: 'VP Engineering',
        location: 'New York, NY',
        candidateSalary: 1200000,
      );

      expect(benchmark.percentile, equals(99.0));
      expect(benchmark.tier, equals('Executive Tier'));
    });

    test('Handles all seniority tiers consistently (Junior, Mid, Senior, Lead, Principal)', () {
      const tiers = ['junior', 'mid', 'senior', 'lead', 'principal'];
      for (final tier in tiers) {
        final benchmark = SalaryPercentileCalculator.calculate(
          seniority: tier,
          role: 'Software Engineer',
          location: 'Remote',
          candidateSalary: 150000,
        );
        expect(benchmark.p25, lessThan(benchmark.p50));
        expect(benchmark.p50, lessThan(benchmark.p75));
        expect(benchmark.p75, lessThan(benchmark.p90));
      }
    });
  });
}
