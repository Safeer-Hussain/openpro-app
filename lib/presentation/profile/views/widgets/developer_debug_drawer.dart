import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/app_feedback.dart';
import '../../viewmodels/debug_settings_viewmodel.dart';
import '../../../job_feed/viewmodels/job_feed_viewmodel.dart';
import '../../../social_feed/viewmodels/social_feed_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';

class DeveloperDebugDrawer extends StatelessWidget {
  const DeveloperDebugDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Consumer<DebugSettingsViewModel>(
        builder: (context, vm, _) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.terminal_rounded,
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Developer & Recruiter Debugger',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Local Mock Network & Push Dispatcher',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 24),

                // Simulated Network Latency
                Text(
                  'Simulated Dio Latency (${vm.latencyMs} ms)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Slider(
                  value: vm.latencyMs.toDouble(),
                  min: 200,
                  max: 2000,
                  divisions: 18,
                  label: '${vm.latencyMs} ms',
                  onChanged: (val) => vm.setLatency(val.toInt()),
                ),
                const SizedBox(height: 12),

                // HTTP 503 Simulation
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Simulate HTTP 503 Service Unavailable',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Tests offline fallback & error retry states.',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  value: vm.simulate503,
                  onChanged: (val) {
                    vm.setSimulate503(val);
                    AppFeedback.showWarning(
                      context,
                      val
                          ? 'HTTP 503 Error simulation active.'
                          : 'Normal network simulation restored.',
                    );
                  },
                ),
                const Divider(height: 24),

                // Push Notification Trigger
                Text(
                  'Simulated In-App Push Triggers',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.notifications_active_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Dispatch Recruiter Match Push',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  onPressed: () {
                    vm.triggerRecruiterMatch(
                      company: 'CloudScale Global',
                      role: 'Principal Flutter Architect',
                      score: 96,
                    );
                    AppFeedback.showSuccess(
                      context,
                      'Recruiter match push notification dispatched.',
                    );
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondaryContainer,
                    foregroundColor: colorScheme.secondary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text(
                    'Dispatch AI Interview Invite',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  onPressed: () {
                    vm.triggerRecruiterMatch(
                      company: 'QuantumAI Labs',
                      role: 'Staff AI Mobile Systems Lead',
                      score: 92,
                    );
                    AppFeedback.showSuccess(
                      context,
                      'Recruiter match push notification dispatched.',
                    );
                  },
                ),
                const Divider(height: 28),

                // Database Reset
                Text(
                  'SQLite Graph Reset',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    'Reset SQLite Seed Database',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                  onPressed: () async {
                    await vm.resetDatabase();
                    if (context.mounted) {
                      context.read<JobFeedViewModel>().loadJobs();
                      context.read<SocialFeedViewModel>().loadData();
                      context.read<ProfileViewModel>().loadProfile();
                      Navigator.pop(context);
                      AppFeedback.showSuccess(
                        context,
                        'Local SQLite database successfully reset to seed data.',
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
