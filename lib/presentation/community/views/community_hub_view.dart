import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../viewmodels/community_viewmodel.dart';
import 'widgets/create_event_modal.dart';
import 'widgets/event_card.dart';
import 'widgets/group_card.dart';

class CommunityHubView extends StatelessWidget {
  const CommunityHubView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<CommunityViewModel>(
      builder: (context, vm, _) {
        final isGroupsTab = vm.selectedTabIndex == 0;

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            heroTag: isGroupsTab ? 'fab_groups_create' : 'fab_events_create',
            icon: Icon(
              isGroupsTab
                  ? Icons.group_add_rounded
                  : Icons.event_available_rounded,
              size: 20,
            ),
            label: Text(
              isGroupsTab ? 'Explore Guilds' : '+ Host Event',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            onPressed: () {
              if (isGroupsTab) {
                AppFeedback.showInfo(
                  context,
                  'Browsing all verified tech guilds.',
                );
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const CreateEventModal(),
                );
              }
            },
          ),
          body: Column(
            children: [
              // Segmented Tab Bar Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                color: colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment<int>(
                            value: 0,
                            label: Text(
                              'Guilds',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            icon: Icon(Icons.hub_rounded, size: 16),
                          ),
                          ButtonSegment<int>(
                            value: 1,
                            label: Text(
                              'Events',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            icon: Icon(Icons.event_seat_rounded, size: 16),
                          ),
                        ],
                        selected: {vm.selectedTabIndex},
                        onSelectionChanged: (set) {
                          vm.setTabIndex(set.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Body Content
              Expanded(
                child: vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : isGroupsTab
                    ? _buildGroupsList(context, vm)
                    : _buildEventsList(context, vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGroupsList(BuildContext context, CommunityViewModel vm) {
    final groups = vm.groups;
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 260,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return GroupCard(group: groups[index]);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return GroupCard(group: groups[index]);
      },
    );
  }

  Widget _buildEventsList(BuildContext context, CommunityViewModel vm) {
    final events = vm.events;
    final orientation = MediaQuery.of(context).orientation;

    if (orientation == Orientation.landscape) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 310,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: events.length,
        itemBuilder: (context, index) {
          return EventCard(event: events[index]);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: events.length,
      itemBuilder: (context, index) {
        return EventCard(event: events[index]);
      },
    );
  }
}
