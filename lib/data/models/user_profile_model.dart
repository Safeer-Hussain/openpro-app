import 'dart:convert';

import '../../domain/entities/user_profile_entity.dart';

class ExperienceModel extends ExperienceEntity {
  const ExperienceModel({
    required super.id,
    required super.userId,
    required super.role,
    required super.company,
    required super.location,
    required super.startDate,
    required super.endDate,
    required super.isCurrent,
    required super.description,
  });

  factory ExperienceModel.fromMap(Map<String, dynamic> map) {
    return ExperienceModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      role: map['role'] as String,
      company: map['company'] as String,
      location: map['location'] as String,
      startDate: map['start_date'] as String,
      endDate: map['end_date'] as String,
      isCurrent: (map['is_current'] as num?)?.toInt() == 1,
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'role': role,
      'company': company,
      'location': location,
      'start_date': startDate,
      'end_date': endDate,
      'is_current': isCurrent ? 1 : 0,
      'description': description,
    };
  }
}

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.techStack,
    required super.githubUrl,
    required super.liveUrl,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(val.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return ProjectModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      techStack: parseList(map['tech_stack']),
      githubUrl: map['github_url'] as String,
      liveUrl: map['live_url'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'tech_stack': jsonEncode(techStack),
      'github_url': githubUrl,
      'live_url': liveUrl,
    };
  }
}

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    required super.title,
    required super.company,
    required super.location,
    required super.bio,
    required super.avatarUrl,
    required super.isOpenToWork,
    required super.isHiring,
    required super.skills,
    required super.experiences,
    required super.projects,
    required super.profileViews,
    required super.recruiterAppearances,
    required super.aiMatchRateBoost,
  });

  factory UserProfileModel.fromMap(
    Map<String, dynamic> map, {
    List<ExperienceModel> experiences = const [],
    List<ProjectModel> projects = const [],
  }) {
    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      try {
        final decoded = jsonDecode(val.toString());
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
      return [];
    }

    return UserProfileModel(
      id: map['id'] as String,
      name: map['name'] as String,
      title: map['title'] as String,
      company: map['company'] as String,
      location: map['location'] as String,
      bio: map['bio'] as String,
      avatarUrl: map['avatar_url'] as String,
      isOpenToWork: (map['is_open_to_work'] as num?)?.toInt() == 1,
      isHiring: (map['is_hiring'] as num?)?.toInt() == 1,
      skills: parseList(map['skills']),
      experiences: experiences,
      projects: projects,
      profileViews: (map['profile_views'] as num?)?.toInt() ?? 0,
      recruiterAppearances:
          (map['recruiter_appearances'] as num?)?.toInt() ?? 0,
      aiMatchRateBoost: (map['ai_match_rate_boost'] as num?)?.toInt() ?? 30,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'company': company,
      'location': location,
      'bio': bio,
      'avatar_url': avatarUrl,
      'is_open_to_work': isOpenToWork ? 1 : 0,
      'is_hiring': isHiring ? 1 : 0,
      'skills': jsonEncode(skills),
      'profile_views': profileViews,
      'recruiter_appearances': recruiterAppearances,
      'ai_match_rate_boost': aiMatchRateBoost,
    };
  }
}
