import 'package:flutter/material.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/job_entity.dart';
import '../../viewmodels/job_feed_viewmodel.dart';
import 'salary_distribution_card.dart';

import 'package:provider/provider.dart';

class SmartApplyModal extends StatefulWidget {
  final JobEntity job;

  const SmartApplyModal({super.key, required this.job});

  @override
  State<SmartApplyModal> createState() => _SmartApplyModalState();
}

class _SmartApplyModalState extends State<SmartApplyModal> {
  final _formKey = GlobalKey<FormState>();
  final _coverNoteController = TextEditingController();
  final _portfolioController = TextEditingController(
    text: 'https://github.com/Safeer-Hussain',
  );
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _coverNoteController.text =
        'I am excited to apply for ${widget.job.title} at ${widget.job.company}. My background in Flutter architecture, offline-first SQLite sync, and reactive state management matches your technical stack.';
  }

  @override
  void dispose() {
    _coverNoteController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final vm = context.read<JobFeedViewModel>();
    final success = await vm.applyToJob(
      jobId: widget.job.id,
      coverNote: _coverNoteController.text.trim(),
      portfolioUrl: _portfolioController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        AppFeedback.showSuccess(
          context,
          'Smart Application submitted to ${widget.job.company}. Status: Applied.',
        );
      } else {
        AppFeedback.showError(context, 'Application failed. Please retry.');
      }
    }
  }

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
          child: Form(
            key: _formKey,
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
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(widget.job.companyLogo),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1-Tap Smart Apply',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${widget.job.title} • ${widget.job.company}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'AI Match: ${widget.job.matchScore}%. Your indexed profile skills match ${widget.job.skills.take(3).join(", ")}.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SalaryDistributionCard(job: widget.job),
                const SizedBox(height: 16),
                Text(
                  'Tailored Cover Pitch *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _coverNoteController,
                  maxLines: 4,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Cover pitch cannot be empty.';
                    }
                    if (value.trim().length < 20) {
                      return 'Please provide at least 20 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  'Verified Portfolio / GitHub URL *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _portfolioController,
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Portfolio link is required.';
                    }
                    if (!value.startsWith('http://') &&
                        !value.startsWith('https://')) {
                      return 'Please enter a valid URL starting with https://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Text(
                            'Confirm & Send Application',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
