import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/core/theme/app_theme.dart';
import 'package:open_pro/domain/entities/job_entity.dart';
import 'package:open_pro/presentation/job_feed/views/widgets/salary_distribution_card.dart';

void main() {
  testWidgets(
    'SalaryDistributionCard renders benchmarks and percentile indicator',
    (tester) async {
      const testJob = JobEntity(
        id: 'job_test_01',
        title: 'Principal Flutter Engineer',
        company: 'TechCorp Labs',
        companyLogo: 'assets/images/techcorp.png',
        location: 'Remote (US)',
        workplaceType: 'Remote',
        employmentType: 'Full-time',
        salaryMin: 195000,
        salaryMax: 230000,
        salaryCurrency: 'USD',
        equity: '0.1% - 0.25%',
        matchScore: 92,
        skills: ['Flutter', 'Dart', 'Clean Architecture'],
        description: 'Lead mobile engineering efforts across global platforms.',
        requirements: ['7+ years experience in Dart and Flutter'],
        postedDate: '2 days ago',
        isBookmarked: false,
        applicationStatus: 'none',
        recruiterName: 'Elena Rostova',
        recruiterTitle: 'Director of Talent Acquisition',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SalaryDistributionCard(job: testJob),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Market Compensation Benchmark'), findsOneWidget);
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
      expect(find.textContaining('Principal Flutter Engineer'), findsOneWidget);
      expect(find.text('50th (Median)'), findsOneWidget);
      expect(find.text('75th'), findsOneWidget);
      expect(find.text('90th'), findsOneWidget);
    },
  );
}
