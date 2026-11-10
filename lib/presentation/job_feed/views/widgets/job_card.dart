import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/entities/job_entity.dart';
import '../../viewmodels/job_feed_viewmodel.dart';
import 'match_score_ring.dart';
import 'share_job_sheet.dart';
import 'smart_apply_modal.dart';

class JobCard extends StatelessWidget {
  final JobEntity job;
  final bool isCompact;
  final bool isSelected;
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.job,
    this.isCompact = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isCompact) {
      return _buildCompactCard(context, colorScheme);
    }
    return _buildExpandedCard(context, colorScheme);
  }

  Widget _buildCompactCard(BuildContext context, ColorScheme colorScheme) {
    final vm = context.read<JobFeedViewModel>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.surfaceContainerHighest
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: AssetImage(job.companyLogo),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        job.company,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                MatchScoreRing(score: job.matchScore, size: 38),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '\$${job.salaryMin ~/ 1000}k - \$${job.salaryMax ~/ 1000}k',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  job.workplaceType,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    job.isBookmarked
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 18,
                    color: job.isBookmarked
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () => vm.toggleBookmark(job.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedCard(BuildContext context, ColorScheme colorScheme) {
    final vm = context.read<JobFeedViewModel>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(job.companyLogo),
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job.company,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              MatchScoreRing(score: job.matchScore, size: 52),
            ],
          ),
          const SizedBox(height: 14),

          // Compensation & Location Chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '\$${job.salaryMin ~/ 1000}k - \$${job.salaryMax ~/ 1000}k / yr',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Equity: ${job.equity}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.workplaceType,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            job.description,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Tech Stack Chips
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: job.skills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.7,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Recruiter Spotlight & Application Status Tracker
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${job.recruiterName} • ${job.recruiterTitle}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusBadge(context, job.applicationStatus, colorScheme),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              IconButton.outlined(
                icon: Icon(
                  job.isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: job.isBookmarked
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                onPressed: () => vm.toggleBookmark(job.id),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                icon: Icon(
                  Icons.share_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => ShareJobSheet(job: job),
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: job.isApplied
                        ? colorScheme.tertiary
                        : colorScheme.primary,
                    foregroundColor: job.isApplied
                        ? colorScheme.onTertiary
                        : colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: Icon(
                    job.isApplied
                        ? Icons.check_circle_outline_rounded
                        : Icons.flash_on_rounded,
                    size: 18,
                  ),
                  label: Text(
                    job.isApplied ? 'Application Active' : '1-Tap Smart Apply',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () {
                    if (job.isApplied) {
                      vm.advanceApplicationStatus(job.id);
                    } else {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => SmartApplyModal(job: job),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    String status,
    ColorScheme colorScheme,
  ) {
    String label = 'Open';
    Color bg = colorScheme.surfaceContainer;
    Color fg = colorScheme.onSurfaceVariant;

    if (status == 'applied') {
      label = 'Applied';
      bg = colorScheme.primaryContainer;
      fg = colorScheme.primary;
    } else if (status == 'inReview') {
      label = 'In Review';
      bg = colorScheme.secondaryContainer;
      fg = colorScheme.secondary;
    } else if (status == 'interviewScheduled') {
      label = 'Interview Scheduled';
      bg = colorScheme.tertiary.withValues(alpha: 0.2);
      fg = colorScheme.tertiary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}
