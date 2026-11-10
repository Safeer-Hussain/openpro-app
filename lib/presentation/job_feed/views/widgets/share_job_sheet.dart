import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/job_entity.dart';
import '../../../social_feed/viewmodels/social_feed_viewmodel.dart';

import 'package:provider/provider.dart';

class ShareJobSheet extends StatelessWidget {
  final JobEntity job;

  const ShareJobSheet({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Share Opportunity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${job.title} • ${job.company}',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.copy_rounded,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Copy Job Summary',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Copies formatted compensation, requirements, and recruiter details.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () async {
                  final summary =
                      '${job.title} at ${job.company}\nSalary: \$${job.salaryMin ~/ 1000}k - \$${job.salaryMax ~/ 1000}k • Equity: ${job.equity}\nLocation: ${job.location} (${job.workplaceType})\nRecruiter: ${job.recruiterName} (${job.recruiterTitle})\nApply via OpenPro';
                  await Clipboard.setData(ClipboardData(text: summary));
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppFeedback.showSuccess(
                      context,
                      'Job summary copied to clipboard.',
                    );
                  }
                },
              ),
              const Divider(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.repeat_rounded,
                    color: colorScheme.tertiary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Repost to OpenPro Network Feed',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Shares this role directly with your professional followers.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () async {
                  final socialVm = context.read<SocialFeedViewModel>();
                  await socialVm.createPost(
                    content:
                        'Highly recommended opening: ${job.title} at ${job.company}. Matches our architectural standards. Salary band: \$${job.salaryMin ~/ 1000}k-\$${job.salaryMax ~/ 1000}k.',
                    tags: ['#Hiring', '#Flutter', '#EngineeringCareers'],
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppFeedback.showSuccess(
                      context,
                      'Opportunity reposted to Network Feed.',
                    );
                  }
                },
              ),
              const Divider(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.badge_rounded,
                    color: colorScheme.secondary,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Export AI Match Card',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  'Generates a certified candidate compatibility summary for this role.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  AppFeedback.showInfo(
                    context,
                    'AI Match Card (${job.matchScore}%) exported.',
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
