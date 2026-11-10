import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_tables.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../models/chat_message_model.dart';
import 'job_repository.dart';
import 'profile_repository.dart';

class AiAssistantRepository {
  final AppDatabase database;
  final ProfileRepository profileRepository;
  final JobRepository jobRepository;

  AiAssistantRepository({
    required this.database,
    required this.profileRepository,
    required this.jobRepository,
  });

  Future<List<ChatMessageEntity>> getMessages() async {
    final db = await database.database;
    final maps = await db.query(
      DatabaseTables.chatMessages,
      orderBy: 'rowid ASC',
    );
    return maps.map((m) => ChatMessageModel.fromMap(m)).toList();
  }

  Future<void> saveMessage(ChatMessageEntity message) async {
    final db = await database.database;
    final model = ChatMessageModel(
      id: message.id,
      sender: message.sender,
      content: message.content,
      timestamp: message.timestamp,
      actionChips: message.actionChips,
    );
    await db.insert(
      DatabaseTables.chatMessages,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearMessages() async {
    final db = await database.database;
    await db.delete(DatabaseTables.chatMessages);
  }

  /// Streams tokens simulating on-device LLM inference grounded in the local career graph.
  Stream<String> streamResponse(String userPrompt) async* {
    final profile = await profileRepository.getUserProfile();
    final jobs = await jobRepository.getJobs();

    final responseText = _generateContextualResponse(userPrompt, profile, jobs);

    // Yield in small token chunks
    final words = responseText.split(' ');
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      yield i == 0 ? words[i] : ' ${words[i]}';
    }
  }

  String _generateContextualResponse(
    String prompt,
    UserProfileEntity? profile,
    List<JobEntity> jobs,
  ) {
    final lower = prompt.toLowerCase();
    final candidateName = profile?.name ?? 'Candidate';
    final candidateSkills = profile?.skills ?? [];
    final appliedJobs = jobs.where((j) => j.isApplied).toList();
    final savedJobs = jobs.where((j) => j.isBookmarked).toList();

    if (lower.contains('analyze') || lower.contains('match')) {
      final topJob = jobs.isNotEmpty ? jobs.first : null;
      return 'Career Graph Match Analysis for $candidateName:\n\n'
          'Your profile demonstrates strong alignment with high-tier Flutter architectural roles. '
          'Evaluating your ${candidateSkills.length} indexed core competencies against active opportunities:\n\n'
          '1. ${topJob?.title ?? "Principal Flutter Architect"} at ${topJob?.company ?? "CloudScale Global"}: '
          '${topJob?.matchScore ?? 96}% match rating. Strong overlap in State Management, SQLite, and System Design.\n'
          '2. Current Profile Strength: High recruiter visibility (${profile?.recruiterAppearances ?? 612} searches, '
          '+${profile?.aiMatchRateBoost ?? 30}% interview conversion rate).\n\n'
          'Recommendation: Highlight your zero-jank 120 FPS optimization and offline-first database architectures in technical screenings.';
    } else if (lower.contains('cover') || lower.contains('pitch')) {
      return 'Tailored Executive Pitch for $candidateName:\n\n'
          '"Dear Engineering Leadership,\n\n'
          'As a Senior Flutter Architect with proven expertise delivering resilient cross-platform systems at scale, '
          'I specialize in reactive state architectures, offline-first SQLite graph persistence, and native engine optimization. '
          'Having led high-throughput mobile initiatives with crash-free rates exceeding 99.98%, I look forward to accelerating your mobile engineering goals."';
    } else if (lower.contains('skill') || lower.contains('gap')) {
      return 'High-Comp Skill Gap & Market Insights:\n\n'
          'Based on market demand across 250+ enterprise mobile listings:\n'
          '1. On-Device LLM & Token Streaming Integration (Projected +18% salary boost in 2026/2027)\n'
          '2. Dart C++ FFI & Custom Skia/Impeller Shader Optimization\n'
          '3. Hermetic Multi-Target CI/CD Automation matrices\n\n'
          'Your core Flutter and Clean Architecture foundation is in the top 5th percentile.';
    } else if (lower.contains('interview') || lower.contains('question')) {
      return 'Architectural Technical Screening Simulation:\n\n'
          'Question: "In a high-frequency financial or social feed, how do you prevent UI thread frame drops '
          'when concurrently processing batch SQLite transactions and real-time streaming updates?"\n\n'
          'Key Points to articulate:\n'
          '• Isolates / Background worker threads for JSON decoding and DB writes.\n'
          '• Granular Selector/Consumer widget rebuild barriers to avoid full-tree invalidation.\n'
          '• Optimistic UI state mutations coupled with debounced background commits.';
    } else {
      return 'I have processed your query against your OpenPro career index. '
          'You currently have ${savedJobs.length} saved roles and ${appliedJobs.length} active applications. '
          'Your skill graph shows verified mastery in ${candidateSkills.take(4).join(", ")}. '
          'Feel free to ask for a tailored pitch, interview practice, or specific job alignment insights.';
    }
  }
}
