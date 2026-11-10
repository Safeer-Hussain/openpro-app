import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_feedback.dart';
import '../viewmodels/job_feed_viewmodel.dart';
import 'widgets/job_card.dart';

class JobFeedView extends StatelessWidget {
  const JobFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_job_feed',
        icon: const Icon(Icons.tune_rounded, size: 20),
        label: const Text(
          'Filter Roles',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        onPressed: () => _showFilterDialog(context),
      ),
      body: isLandscape
          ? _buildLandscapeLayout(context)
          : _buildPortraitLayout(context),
    );
  }

  Widget _buildPortraitLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<JobFeedViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = vm.jobs;

        return Column(
          children: [
            _buildSearchAndFiltersHeader(context, vm, colorScheme),
            Expanded(
              child: jobs.isEmpty
                  ? _buildEmptyState(context, colorScheme)
                  : vm.viewType == JobFeedViewType.verticalFeed
                  ? PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 80),
                            child: JobCard(job: jobs[index]),
                          ),
                        );
                      },
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            mainAxisExtent: 145,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        return JobCard(
                          job: jobs[index],
                          isCompact: true,
                          onTap: () {
                            vm.selectJob(index);
                            vm.toggleViewType();
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLandscapeLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<JobFeedViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final jobs = vm.jobs;
        final selectedJob = vm.selectedJob;

        return Row(
          children: [
            // Left Master Pane
            SizedBox(
              width: 320,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
                child: Column(
                  children: [
                    _buildCompactSearchBar(context, vm, colorScheme),
                    Expanded(
                      child: jobs.isEmpty
                          ? _buildEmptyState(context, colorScheme)
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              itemCount: jobs.length,
                              itemBuilder: (context, index) {
                                final job = jobs[index];
                                final isSelected = index == vm.selectedJobIndex;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: SizedBox(
                                    height: 120,
                                    child: JobCard(
                                      job: job,
                                      isCompact: true,
                                      isSelected: isSelected,
                                      onTap: () => vm.selectJob(index),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // Right Detail Pane
            Expanded(
              child: selectedJob == null
                  ? _buildEmptyState(context, colorScheme)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: JobCard(job: selectedJob),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFiltersHeader(
    BuildContext context,
    JobFeedViewModel vm,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: colorScheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search roles, skills, or companies...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    suffixIcon: vm.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () => vm.setSearchQuery(''),
                          )
                        : null,
                  ),
                  onChanged: vm.setSearchQuery,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: Icon(
                  vm.viewType == JobFeedViewType.verticalFeed
                      ? Icons.grid_view_rounded
                      : Icons.view_agenda_rounded,
                  size: 20,
                ),
                onPressed: vm.toggleViewType,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'All',
                  vm.selectedWorkplaceFilter,
                  (f) => vm.setWorkplaceFilter(f),
                  colorScheme,
                ),
                _buildFilterChip(
                  'Remote',
                  vm.selectedWorkplaceFilter,
                  (f) => vm.setWorkplaceFilter(f),
                  colorScheme,
                ),
                _buildFilterChip(
                  'Hybrid',
                  vm.selectedWorkplaceFilter,
                  (f) => vm.setWorkplaceFilter(f),
                  colorScheme,
                ),
                _buildFilterChip(
                  'On-Site',
                  vm.selectedWorkplaceFilter,
                  (f) => vm.setWorkplaceFilter(f),
                  colorScheme,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Principal',
                  vm.selectedSeniorityFilter,
                  (f) => vm.setSeniorityFilter(f),
                  colorScheme,
                ),
                _buildFilterChip(
                  'Staff',
                  vm.selectedSeniorityFilter,
                  (f) => vm.setSeniorityFilter(f),
                  colorScheme,
                ),
                _buildFilterChip(
                  'Lead',
                  vm.selectedSeniorityFilter,
                  (f) => vm.setSeniorityFilter(f),
                  colorScheme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSearchBar(
    BuildContext context,
    JobFeedViewModel vm,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Filter opportunities...',
          prefixIcon: const Icon(Icons.search_rounded, size: 18),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
        onChanged: vm.setSearchQuery,
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String selectedValue,
    Function(String) onSelected,
    ColorScheme colorScheme,
  ) {
    final isSelected = selectedValue == label;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(label),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
        backgroundColor: colorScheme.surfaceContainer,
        selectedColor: colorScheme.primary,
        checkmarkColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.work_off_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No matching opportunities found',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try clearing your search query or filters.',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final vm = context.read<JobFeedViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Opportunities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Workplace Mode',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['All', 'Remote', 'Hybrid', 'On-Site'].map((m) {
                    return ChoiceChip(
                      label: Text(m),
                      selected: vm.selectedWorkplaceFilter == m,
                      onSelected: (val) {
                        if (val) vm.setWorkplaceFilter(m);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Seniority Level',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['All', 'Principal', 'Staff', 'Senior', 'Lead'].map(
                    (s) {
                      return ChoiceChip(
                        label: Text(s),
                        selected: vm.selectedSeniorityFilter == s,
                        onSelected: (val) {
                          if (val) vm.setSeniorityFilter(s);
                        },
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      AppFeedback.showSuccess(
                        context,
                        'Filters applied successfully.',
                      );
                    },
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
