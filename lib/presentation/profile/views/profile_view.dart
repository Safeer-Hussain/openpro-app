import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/profile_viewmodel.dart';
import 'widgets/developer_debug_drawer.dart';
import 'widgets/edit_profile_modal.dart';
import 'widgets/endorsed_skills_section.dart';
import 'widgets/experience_timeline.dart';
import 'widgets/profile_header.dart';
import 'widgets/recruiter_analytics_card.dart';
import 'widgets/skills_cloud.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Consumer<ProfileViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading || vm.profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = vm.profile!;

        return Scaffold(
          endDrawer: const DeveloperDebugDrawer(),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'fab_profile_edit',
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: const Text(
              'Edit Profile',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => EditProfileModal(profile: profile),
              );
            },
          ),
          body: isLandscape
              ? _buildLandscapeLayout(context, profile)
              : _buildPortraitLayout(context, profile),
        );
      },
    );
  }

  Widget _buildPortraitLayout(BuildContext context, dynamic profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      child: Column(
        children: [
          ProfileHeader(profile: profile),
          RecruiterAnalyticsCard(profile: profile),
          SkillsCloud(skills: profile.skills),
          const EndorsedSkillsSection(),
          ExperienceTimeline(
            experiences: profile.experiences,
            projects: profile.projects,
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(BuildContext context, dynamic profile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Header and Skills
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 8, 6, 80),
            child: Column(
              children: [
                ProfileHeader(profile: profile),
                SkillsCloud(skills: profile.skills),
                const EndorsedSkillsSection(),
              ],
            ),
          ),
        ),

        // Right Column: Recruiter Analytics & Timeline
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(6, 8, 12, 80),
            child: Column(
              children: [
                RecruiterAnalyticsCard(profile: profile),
                ExperienceTimeline(
                  experiences: profile.experiences,
                  projects: profile.projects,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
