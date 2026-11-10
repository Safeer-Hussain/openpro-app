import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_tables.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../models/user_profile_model.dart';

class ProfileRepository {
  final AppDatabase database;

  ProfileRepository({required this.database});

  Future<UserProfileEntity?> getUserProfile([
    String userId = AppConstants.defaultUserId,
  ]) async {
    final db = await database.database;
    final userMaps = await db.query(
      DatabaseTables.userProfile,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (userMaps.isEmpty) return null;

    final expMaps = await db.query(
      DatabaseTables.experiences,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'rowid ASC',
    );
    final projMaps = await db.query(
      DatabaseTables.projects,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'rowid ASC',
    );

    final experiences = expMaps.map((m) => ExperienceModel.fromMap(m)).toList();
    final projects = projMaps.map((m) => ProjectModel.fromMap(m)).toList();

    return UserProfileModel.fromMap(
      userMaps.first,
      experiences: experiences,
      projects: projects,
    );
  }

  Future<void> updateProfile(UserProfileEntity profile) async {
    final db = await database.database;
    final model = UserProfileModel(
      id: profile.id,
      name: profile.name,
      title: profile.title,
      company: profile.company,
      location: profile.location,
      bio: profile.bio,
      avatarUrl: profile.avatarUrl,
      isOpenToWork: profile.isOpenToWork,
      isHiring: profile.isHiring,
      skills: profile.skills,
      experiences: profile.experiences,
      projects: profile.projects,
      profileViews: profile.profileViews,
      recruiterAppearances: profile.recruiterAppearances,
      aiMatchRateBoost: profile.aiMatchRateBoost,
    );

    await db.update(
      DatabaseTables.userProfile,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  Future<bool> toggleOpenToWork(String userId) async {
    final db = await database.database;
    final results = await db.query(
      DatabaseTables.userProfile,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (results.isEmpty) return false;

    final current = (results.first['is_open_to_work'] as num?)?.toInt() == 1;
    final nextVal = !current;

    await db.update(
      DatabaseTables.userProfile,
      {'is_open_to_work': nextVal ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );

    return nextVal;
  }

  Future<void> addExperience(ExperienceEntity experience) async {
    final db = await database.database;
    final model = ExperienceModel(
      id: experience.id,
      userId: experience.userId,
      role: experience.role,
      company: experience.company,
      location: experience.location,
      startDate: experience.startDate,
      endDate: experience.endDate,
      isCurrent: experience.isCurrent,
      description: experience.description,
    );
    await db.insert(
      DatabaseTables.experiences,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> addProject(ProjectEntity project) async {
    final db = await database.database;
    final model = ProjectModel(
      id: project.id,
      userId: project.userId,
      title: project.title,
      description: project.description,
      techStack: project.techStack,
      githubUrl: project.githubUrl,
      liveUrl: project.liveUrl,
    );
    await db.insert(
      DatabaseTables.projects,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
