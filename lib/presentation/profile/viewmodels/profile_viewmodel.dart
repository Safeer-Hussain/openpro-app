import 'package:flutter/foundation.dart';

import '../../../core/services/service_locator.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../data/repositories/skill_repository.dart';
import '../../../domain/entities/skill_endorsement.dart';
import '../../../domain/entities/user_profile_entity.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository repository;
  final SkillRepository? skillRepository;

  UserProfileEntity? _profile;
  List<SkillEndorsement> _endorsements = [];
  bool _isLoading = true;

  ProfileViewModel({required this.repository, SkillRepository? skillRepository})
    : skillRepository =
          skillRepository ??
          (sl.isRegistered<SkillRepository>() ? sl<SkillRepository>() : null) {
    loadProfile();
  }

  UserProfileEntity? get profile => _profile;
  List<SkillEndorsement> get endorsements => _endorsements;
  bool get isLoading => _isLoading;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await repository.getUserProfile();
      if (_profile != null && skillRepository != null) {
        _endorsements = await skillRepository!.getEndorsementsForUser(
          _profile!.id,
        );
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadEndorsements([String? userId]) async {
    if (skillRepository == null) return;
    final targetId = userId ?? _profile?.id;
    if (targetId == null) return;
    try {
      _endorsements = await skillRepository!.getEndorsementsForUser(targetId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleEndorsement(String skillName) async {
    if (_profile == null) return;

    final index = _endorsements.indexWhere((e) => e.skillName == skillName);
    if (index == -1) return;

    final current = _endorsements[index];
    final newIsEndorsed = !current.isEndorsedByMe;
    final newCount = newIsEndorsed
        ? current.count + 1
        : (current.count - 1).clamp(0, 9999);

    final updatedTopEndorsers = List<Endorser>.from(current.topEndorsers);
    if (newIsEndorsed) {
      updatedTopEndorsers.insert(
        0,
        const Endorser(
          id: 'me',
          name: 'You',
          title: 'Verified Peer',
          avatarUrl: 'assets/images/safeer_avatar.png',
        ),
      );
    } else {
      updatedTopEndorsers.removeWhere((e) => e.id == 'me' || e.name == 'You');
    }

    final updatedItem = current.copyWith(
      isEndorsedByMe: newIsEndorsed,
      count: newCount,
      topEndorsers: updatedTopEndorsers,
    );

    _endorsements[index] = updatedItem;
    notifyListeners();

    if (skillRepository != null) {
      try {
        final synced = await skillRepository!.toggleEndorsement(
          userId: _profile!.id,
          skillName: skillName,
          endorserName: 'You',
          endorserTitle: 'Verified Peer',
          endorserAvatar: 'assets/images/safeer_avatar.png',
        );
        _endorsements[index] = synced;
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> toggleOpenToWork() async {
    if (_profile == null) return;

    final updated = _profile!.copyWith(isOpenToWork: !_profile!.isOpenToWork);
    _profile = updated;
    notifyListeners();

    try {
      await repository.toggleOpenToWork(updated.id);
    } catch (_) {}
  }

  Future<void> toggleHiring() async {
    if (_profile == null) return;

    final updated = _profile!.copyWith(isHiring: !_profile!.isHiring);
    _profile = updated;
    notifyListeners();

    try {
      await repository.updateProfile(updated);
    } catch (_) {}
  }

  Future<void> updateBioAndTitle({
    required String name,
    required String title,
    required String company,
    required String location,
    required String bio,
    required List<String> skills,
  }) async {
    if (_profile == null) return;

    final updated = _profile!.copyWith(
      name: name,
      title: title,
      company: company,
      location: location,
      bio: bio,
      skills: skills,
    );

    _profile = updated;
    notifyListeners();

    try {
      await repository.updateProfile(updated);
    } catch (_) {}
  }

  Future<void> addExperience({
    required String role,
    required String company,
    required String location,
    required String startDate,
    required String endDate,
    required bool isCurrent,
    required String description,
  }) async {
    if (_profile == null) return;

    final newExp = ExperienceEntity(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      userId: _profile!.id,
      role: role,
      company: company,
      location: location,
      startDate: startDate,
      endDate: endDate,
      isCurrent: isCurrent,
      description: description,
    );

    final updatedExperiences = List<ExperienceEntity>.from(
      _profile!.experiences,
    )..insert(0, newExp);
    _profile = _profile!.copyWith(experiences: updatedExperiences);
    notifyListeners();

    try {
      await repository.addExperience(newExp);
    } catch (_) {}
  }

  Future<void> addProject({
    required String title,
    required String description,
    required List<String> techStack,
    required String githubUrl,
    required String liveUrl,
  }) async {
    if (_profile == null) return;

    final newProj = ProjectEntity(
      id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
      userId: _profile!.id,
      title: title,
      description: description,
      techStack: techStack,
      githubUrl: githubUrl,
      liveUrl: liveUrl,
    );

    final updatedProjects = List<ProjectEntity>.from(_profile!.projects)
      ..insert(0, newProj);
    _profile = _profile!.copyWith(projects: updatedProjects);
    notifyListeners();

    try {
      await repository.addProject(newProj);
    } catch (_) {}
  }
}
