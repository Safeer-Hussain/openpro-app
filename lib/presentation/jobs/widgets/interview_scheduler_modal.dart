import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/job_entity.dart';
import '../viewmodels/interview_scheduler_viewmodel.dart';

class InterviewSchedulerModal extends StatelessWidget {
  final JobEntity job;

  const InterviewSchedulerModal({super.key, required this.job});

  static Future<bool?> show(BuildContext context, {required JobEntity job}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (c) => InterviewSchedulerViewModel(
              repository: Provider.of(c, listen: false),
              job: job,
            ),
          ),
        ],
        child: InterviewSchedulerModal(job: job),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<InterviewSchedulerViewModel>(
      builder: (context, viewModel, _) {
        final dayFormat = DateFormat('EEE d');
        final monthFormat = DateFormat('MMM yyyy');
        final timeFormat = DateFormat('h:mm a');

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(job.companyLogo),
                        backgroundColor: colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select Interview Availability',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${job.title} • ${job.company}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: viewModel.selectedCount > 0
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: viewModel.selectedCount > 0
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          '${viewModel.selectedCount}/3 Slots',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: viewModel.selectedCount > 0
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Select up to three 30-minute interview windows from the next 7 days. At least 24 hours advance notice is enforced.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 11.5,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rolling 7-Day Window (${monthFormat.format(viewModel.selectedDay)})',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 58,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: viewModel.availableDays.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final day = viewModel.availableDays[idx];
                        final isDaySelected = day.year == viewModel.selectedDay.year &&
                            day.month == viewModel.selectedDay.month &&
                            day.day == viewModel.selectedDay.day;

                        final daySlots = viewModel.getSlotsForDay(day);
                        final selectedCountOnDay = daySlots.where(viewModel.isSlotSelected).length;

                        return InkWell(
                          onTap: () => viewModel.selectDay(day),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 66,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isDaySelected
                                  ? colorScheme.primaryContainer
                                  : colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDaySelected
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant,
                                width: isDaySelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  dayFormat.format(day),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isDaySelected ? FontWeight.bold : FontWeight.w500,
                                    color: isDaySelected
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurface,
                                  ),
                                ),
                                if (selectedCountOnDay > 0) ...[
                                  const SizedBox(height: 3),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Available 30-Minute Slots',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: viewModel.getSlotsForDay(viewModel.selectedDay).map((slot) {
                      final isValid = viewModel.isSlotValid(slot);
                      final isSelected = viewModel.isSlotSelected(slot);
                      final endTime = slot.add(const Duration(minutes: 30));

                      return InkWell(
                        onTap: isValid ? () => viewModel.toggleSlot(slot) : null,
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : (isValid
                                    ? colorScheme.surfaceContainerHighest
                                    : colorScheme.surfaceContainer.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : (isValid
                                      ? colorScheme.outlineVariant
                                      : colorScheme.outlineVariant.withValues(alpha: 0.3)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.access_time_rounded,
                                size: 14,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : (isValid
                                        ? colorScheme.onSurfaceVariant
                                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${timeFormat.format(slot)} - ${timeFormat.format(endTime)}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : (isValid
                                          ? colorScheme.onSurface
                                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (viewModel.errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: viewModel.canConfirm
                        ? () async {
                            final success = await viewModel.confirmInterview();
                            if (context.mounted) {
                              if (success) {
                                Navigator.of(context).pop(true);
                                AppFeedback.showSuccess(
                                  context,
                                  'Interview slots confirmed with ${job.company}. Status updated to Interview Scheduled.',
                                );
                              } else {
                                AppFeedback.showError(
                                  context,
                                  viewModel.errorMessage ?? 'Failed to schedule slots.',
                                );
                              }
                            }
                          }
                        : null,
                    icon: viewModel.isSubmitting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.calendar_month_outlined, size: 18),
                    label: Text(
                      viewModel.selectedCount > 0
                          ? 'Confirm Interview Availability (${viewModel.selectedCount} Selected)'
                          : 'Select at Least 1 Slot',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
