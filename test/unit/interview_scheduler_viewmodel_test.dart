import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/domain/entities/job_entity.dart';
import 'package:open_pro/presentation/jobs/viewmodels/interview_scheduler_viewmodel.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('InterviewSchedulerViewModel Unit Tests', () {
    late MockJobRepository mockJobRepo;
    late JobEntity testJob;
    final fixedNow = DateTime(2026, 11, 6, 10, 0); // Friday 10:00 AM

    setUp(() {
      mockJobRepo = MockJobRepository();
      testJob = const JobEntity(
        id: 'job_sched_1',
        title: 'Lead Mobile Architect',
        company: 'CloudScale Global',
        companyLogo: 'assets/images/cloudscale.png',
        location: 'Remote',
        workplaceType: 'Remote',
        employmentType: 'Full-time',
        salaryMin: 180000,
        salaryMax: 230000,
        salaryCurrency: 'USD',
        equity: '0.1%',
        description: 'Lead architecture efforts.',
        requirements: ['Flutter experience'],
        skills: ['Flutter', 'Dart'],
        postedDate: '1 day ago',
        isBookmarked: false,
        applicationStatus: 'applied',
        matchScore: 94,
        recruiterName: 'Elena Rostova',
        recruiterTitle: 'Director',
      );
    });

    test('Initializes with a 7-day rolling window starting from tomorrow', () {
      final viewModel = InterviewSchedulerViewModel(
        repository: mockJobRepo,
        job: testJob,
        currentTime: fixedNow,
      );

      expect(viewModel.availableDays.length, equals(7));
      expect(viewModel.availableDays.first.day, equals(7)); // Nov 7
      expect(viewModel.availableDays.last.day, equals(13)); // Nov 13
      expect(viewModel.selectedCount, equals(0));
      expect(viewModel.canConfirm, isFalse);
    });

    test('Enforces minimum 24-hour advance scheduling window', () {
      final viewModel = InterviewSchedulerViewModel(
        repository: mockJobRepo,
        job: testJob,
        currentTime: fixedNow, // Nov 6, 10:00 AM
      );

      // A slot at 9:00 AM on Nov 7 is only 23 hours ahead (< 24h)
      final earlySlot = DateTime(2026, 11, 7, 9, 0);
      expect(viewModel.isSlotValid(earlySlot), isFalse);

      final result = viewModel.toggleSlot(earlySlot);
      expect(result, isFalse);
      expect(viewModel.selectedCount, equals(0));
      expect(viewModel.errorMessage, contains('24 hours'));

      // A slot at 11:30 AM on Nov 7 is 25.5 hours ahead (> 24h)
      final validSlot = DateTime(2026, 11, 7, 11, 30);
      expect(viewModel.isSlotValid(validSlot), isTrue);

      final validResult = viewModel.toggleSlot(validSlot);
      expect(validResult, isTrue);
      expect(viewModel.selectedCount, equals(1));
      expect(viewModel.isSlotSelected(validSlot), isTrue);
    });

    test('Allows selecting up to 3 slots and prevents 4th slot selection', () {
      final viewModel = InterviewSchedulerViewModel(
        repository: mockJobRepo,
        job: testJob,
        currentTime: fixedNow,
      );

      final slot1 = DateTime(2026, 11, 7, 13, 30);
      final slot2 = DateTime(2026, 11, 7, 15, 0);
      final slot3 = DateTime(2026, 11, 8, 10, 0);
      final slot4 = DateTime(2026, 11, 8, 11, 30);

      expect(viewModel.toggleSlot(slot1), isTrue);
      expect(viewModel.toggleSlot(slot2), isTrue);
      expect(viewModel.toggleSlot(slot3), isTrue);
      expect(viewModel.selectedCount, equals(3));
      expect(viewModel.canConfirm, isTrue);

      // Attempting to select 4th slot
      final fourthResult = viewModel.toggleSlot(slot4);
      expect(fourthResult, isFalse);
      expect(viewModel.selectedCount, equals(3));
      expect(viewModel.errorMessage, contains('Maximum of 3'));
    });

    test('Toggling an already selected slot removes it', () {
      final viewModel = InterviewSchedulerViewModel(
        repository: mockJobRepo,
        job: testJob,
        currentTime: fixedNow,
      );

      final slot = DateTime(2026, 11, 7, 15, 0);
      viewModel.toggleSlot(slot);
      expect(viewModel.selectedCount, equals(1));

      viewModel.toggleSlot(slot);
      expect(viewModel.selectedCount, equals(0));
      expect(viewModel.canConfirm, isFalse);
    });

    test(
      'confirmInterview persists slots and updates job application status',
      () async {
        final viewModel = InterviewSchedulerViewModel(
          repository: mockJobRepo,
          job: testJob,
          currentTime: fixedNow,
        );

        final slot1 = DateTime(2026, 11, 7, 13, 30);
        final slot2 = DateTime(2026, 11, 8, 10, 0);
        viewModel.toggleSlot(slot1);
        viewModel.toggleSlot(slot2);

        final success = await viewModel.confirmInterview();
        expect(success, isTrue);

        final persistedSlots = await mockJobRepo.getScheduledSlots(
          jobId: testJob.id,
          userId: viewModel.userId,
        );
        expect(persistedSlots.length, equals(2));
        expect(persistedSlots.first, equals(slot1));
      },
    );
  });
}
