import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:open_pro/core/theme/app_theme.dart';
import 'package:open_pro/domain/entities/job_entity.dart';
import 'package:open_pro/presentation/jobs/viewmodels/interview_scheduler_viewmodel.dart';
import 'package:open_pro/presentation/jobs/widgets/interview_scheduler_modal.dart';
import '../helpers/mock_repositories.dart';

void main() {
  testWidgets('InterviewSchedulerModal renders rolling days and handles slot selection', (tester) async {
    final mockJobRepo = MockJobRepository();
    const testJob = JobEntity(
      id: 'job_sched_test',
      title: 'Principal Systems Architect',
      company: 'TechCorp Labs',
      companyLogo: 'assets/images/techcorp.png',
      location: 'Remote (US)',
      workplaceType: 'Remote',
      employmentType: 'Full-time',
      salaryMin: 200000,
      salaryMax: 250000,
      salaryCurrency: 'USD',
      equity: '0.2%',
      matchScore: 95,
      skills: ['Flutter', 'Systems Design'],
      description: 'Lead mobile systems.',
      requirements: ['7+ years experience'],
      postedDate: 'Today',
      isBookmarked: false,
      applicationStatus: 'applied',
      recruiterName: 'Elena Rostova',
      recruiterTitle: 'Director of Talent Acquisition',
    );

    // Mock now as fixed future time so tomorrow's slots are all > 24 hours
    final fixedNow = DateTime(2026, 11, 6, 8, 0);
    final viewModel = InterviewSchedulerViewModel(
      repository: mockJobRepo,
      job: testJob,
      currentTime: fixedNow,
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<InterviewSchedulerViewModel>.value(
        value: viewModel,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: InterviewSchedulerModal(job: testJob),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Select Interview Availability'), findsOneWidget);
    expect(find.textContaining('Principal Systems Architect'), findsOneWidget);
    expect(find.text('0/3 Slots'), findsOneWidget);
    expect(find.text('Select at Least 1 Slot'), findsOneWidget);

    // Find first valid slot chip and tap it
    final slotFinder = find.textContaining('9:00 AM');
    expect(slotFinder, findsOneWidget);

    await tester.tap(slotFinder);
    await tester.pumpAndSettle();

    // Verify counter updated to 1/3 Slots and button text changed
    expect(find.text('1/3 Slots'), findsOneWidget);
    expect(find.textContaining('Confirm Interview Availability (1 Selected)'), findsOneWidget);

    // Tap confirm button
    final confirmButton = find.byType(FilledButton);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    // Verify slots were persisted to the repository
    final scheduled = await mockJobRepo.getScheduledSlots(
      jobId: testJob.id,
      userId: viewModel.userId,
    );
    expect(scheduled.length, equals(1));
  });
}
