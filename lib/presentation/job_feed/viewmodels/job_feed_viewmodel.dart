import 'package:flutter/foundation.dart';

import '../../../data/repositories/job_repository.dart';
import '../../../domain/entities/job_entity.dart';

enum JobFeedViewType { verticalFeed, gridView }

class JobFeedViewModel extends ChangeNotifier {
  final JobRepository repository;

  List<JobEntity> _jobs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedWorkplaceFilter = 'All'; // All, Remote, Hybrid, On-Site
  String _selectedSeniorityFilter = 'All'; // All, Principal, Staff, Senior
  int _selectedJobIndex = 0;
  JobFeedViewType _viewType = JobFeedViewType.verticalFeed;

  JobFeedViewModel({required this.repository}) {
    loadJobs();
  }

  List<JobEntity> get jobs => _filteredJobs();
  List<JobEntity> get rawJobs => _jobs;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedWorkplaceFilter => _selectedWorkplaceFilter;
  String get selectedSeniorityFilter => _selectedSeniorityFilter;
  int get selectedJobIndex => _selectedJobIndex;
  JobFeedViewType get viewType => _viewType;

  JobEntity? get selectedJob {
    final list = _filteredJobs();
    if (list.isEmpty) return null;
    if (_selectedJobIndex >= list.length) {
      _selectedJobIndex = 0;
    }
    return list[_selectedJobIndex];
  }

  Future<void> loadJobs() async {
    _isLoading = true;
    notifyListeners();
    try {
      _jobs = await repository.getJobs();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _selectedJobIndex = 0;
    notifyListeners();
  }

  void setWorkplaceFilter(String filter) {
    _selectedWorkplaceFilter = filter;
    _selectedJobIndex = 0;
    notifyListeners();
  }

  void setSeniorityFilter(String filter) {
    _selectedSeniorityFilter = filter;
    _selectedJobIndex = 0;
    notifyListeners();
  }

  void selectJob(int index) {
    _selectedJobIndex = index;
    notifyListeners();
  }

  void toggleViewType() {
    _viewType = _viewType == JobFeedViewType.verticalFeed
        ? JobFeedViewType.gridView
        : JobFeedViewType.verticalFeed;
    notifyListeners();
  }

  List<JobEntity> _filteredJobs() {
    return _jobs.where((job) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = job.title.toLowerCase().contains(q);
        final matchesCompany = job.company.toLowerCase().contains(q);
        final matchesSkill = job.skills.any((s) => s.toLowerCase().contains(q));
        if (!matchesTitle && !matchesCompany && !matchesSkill) {
          return false;
        }
      }

      // Workplace filter
      if (_selectedWorkplaceFilter != 'All') {
        if (job.workplaceType.toLowerCase() !=
            _selectedWorkplaceFilter.toLowerCase()) {
          return false;
        }
      }

      // Seniority filter
      if (_selectedSeniorityFilter != 'All') {
        if (!job.title.toLowerCase().contains(
          _selectedSeniorityFilter.toLowerCase(),
        )) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> toggleBookmark(String jobId) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;

    final current = _jobs[index];
    final updated = current.copyWith(isBookmarked: !current.isBookmarked);

    // Optimistic mutation
    _jobs[index] = updated;
    notifyListeners();

    try {
      await repository.toggleBookmark(jobId);
    } catch (_) {
      // Revert if failed
      _jobs[index] = current;
      notifyListeners();
    }
  }

  Future<bool> applyToJob({
    required String jobId,
    required String coverNote,
    String? portfolioUrl,
  }) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return false;

    final current = _jobs[index];
    final updated = current.copyWith(applicationStatus: 'applied');

    // Optimistic mutation
    _jobs[index] = updated;
    notifyListeners();

    try {
      await repository.submitApplication(
        jobId: jobId,
        coverNote: coverNote,
        portfolioUrl: portfolioUrl,
      );
      return true;
    } catch (_) {
      _jobs[index] = current;
      notifyListeners();
      return false;
    }
  }

  Future<void> advanceApplicationStatus(String jobId) async {
    final index = _jobs.indexWhere((j) => j.id == jobId);
    if (index == -1) return;

    final current = _jobs[index];
    String nextStatus = 'applied';
    if (current.applicationStatus == 'none') {
      nextStatus = 'applied';
    } else if (current.applicationStatus == 'applied') {
      nextStatus = 'inReview';
    } else if (current.applicationStatus == 'inReview') {
      nextStatus = 'interviewScheduled';
    } else {
      nextStatus = 'applied';
    }

    final updated = current.copyWith(applicationStatus: nextStatus);
    _jobs[index] = updated;
    notifyListeners();

    try {
      await repository.updateApplicationStatus(
        jobId: jobId,
        status: nextStatus,
      );
    } catch (_) {}
  }
}
