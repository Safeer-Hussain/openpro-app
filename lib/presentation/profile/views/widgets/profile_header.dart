import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../domain/entities/user_profile_entity.dart';
import '../../viewmodels/profile_viewmodel.dart';
import 'edit_profile_modal.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfileEntity profile;

  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final vm = context.read<ProfileViewModel>();
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar + Quick Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPress: () {
                  Scaffold.of(context).openEndDrawer();
                  AppFeedback.showInfo(
                    context,
                    'Developer & Recruiter Debug Drawer opened.',
                  );
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: const AssetImage(
                        AssetPaths.safeerAvatar,
                      ),
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                    if (profile.isOpenToWork)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surfaceContainer,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 10,
                            color: colorScheme.onTertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.outlined(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      size: 16,
                      color: colorScheme.onSurface,
                    ),
                    tooltip: 'Toggle Theme',
                    onPressed: () => themeProvider.toggleTheme(),
                  ),
                  const SizedBox(width: 6),
                  IconButton.outlined(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.bug_report_outlined,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    tooltip: 'Recruiter & Latency Debug Drawer',
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filledTonal(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    tooltip: 'Edit Profile Details',
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => EditProfileModal(profile: profile),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name and Role
          Row(
            children: [
              Flexible(
                child: Text(
                  profile.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.verified_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            profile.title,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${profile.company} • ${profile.location}',
            style: TextStyle(
              fontSize: 11.5,
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Bio
          Text(
            profile.bio,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),

          // Interactive Career Status Toggles
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                avatar: Icon(
                  profile.isOpenToWork
                      ? Icons.check_circle_rounded
                      : Icons.work_outline_rounded,
                  size: 14,
                  color: profile.isOpenToWork
                      ? colorScheme.onTertiary
                      : colorScheme.onSurface,
                ),
                label: const Text('Open to Work'),
                selected: profile.isOpenToWork,
                selectedColor: colorScheme.tertiary,
                backgroundColor: colorScheme.surfaceContainerHighest,
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: profile.isOpenToWork
                      ? colorScheme.onTertiary
                      : colorScheme.onSurface,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                onSelected: (_) {
                  vm.toggleOpenToWork();
                  AppFeedback.showSuccess(
                    context,
                    !profile.isOpenToWork
                        ? 'Open to Opportunities status enabled.'
                        : 'Open to Opportunities paused.',
                  );
                },
              ),
              FilterChip(
                avatar: Icon(
                  profile.isHiring
                      ? Icons.check_circle_rounded
                      : Icons.person_add_outlined,
                  size: 14,
                  color: profile.isHiring
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
                label: const Text('We are Hiring'),
                selected: profile.isHiring,
                selectedColor: colorScheme.primary,
                backgroundColor: colorScheme.surfaceContainerHighest,
                labelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: profile.isHiring
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                onSelected: (_) {
                  vm.toggleHiring();
                  AppFeedback.showSuccess(
                    context,
                    !profile.isHiring
                        ? 'Hiring Leader badge enabled.'
                        : 'Hiring Leader badge paused.',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
