import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../constants/app_constants.dart';
import '../constants/asset_paths.dart';
import 'database_tables.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  Database? _db;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (kIsWeb) {
      path = 'openpro_app.db';
    } else {
      final docDir = await getApplicationDocumentsDirectory();
      path = p.join(docDir.path, 'openpro_app.db');
    }

    final db = await openDatabase(path, version: 1, onCreate: _onCreate);

    await _ensureTables(db);
    return db;
  }

  Future<void> _ensureTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.skillEndorsements} (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        skill_name TEXT NOT NULL,
        endorser_name TEXT NOT NULL,
        endorser_title TEXT NOT NULL,
        endorser_avatar TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_endorsed_by_me INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${DatabaseTables.applications} (
        id TEXT PRIMARY KEY,
        job_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        status TEXT NOT NULL,
        cover_note TEXT,
        scheduled_slots TEXT,
        applied_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseTables.skillEndorsements}',
    );
    final count = countResult.isNotEmpty
        ? (countResult.first['count'] as int? ?? 0)
        : 0;
    if (count == 0) {
      await _seedSkillEndorsements(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Jobs Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.jobs} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        company TEXT NOT NULL,
        company_logo TEXT NOT NULL,
        location TEXT NOT NULL,
        workplace_type TEXT NOT NULL,
        employment_type TEXT NOT NULL,
        salary_min INTEGER NOT NULL,
        salary_max INTEGER NOT NULL,
        salary_currency TEXT NOT NULL,
        equity TEXT NOT NULL,
        description TEXT NOT NULL,
        requirements TEXT NOT NULL,
        skills TEXT NOT NULL,
        posted_date TEXT NOT NULL,
        is_bookmarked INTEGER NOT NULL DEFAULT 0,
        application_status TEXT NOT NULL DEFAULT 'none',
        match_score INTEGER NOT NULL DEFAULT 85,
        recruiter_name TEXT NOT NULL,
        recruiter_title TEXT NOT NULL
      )
    ''');

    // 2. Posts Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.posts} (
        id TEXT PRIMARY KEY,
        author_name TEXT NOT NULL,
        author_role TEXT NOT NULL,
        author_avatar TEXT NOT NULL,
        author_company TEXT NOT NULL,
        content TEXT NOT NULL,
        code_snippet TEXT,
        code_language TEXT,
        timestamp TEXT NOT NULL,
        likes_count INTEGER NOT NULL DEFAULT 0,
        comments_count INTEGER NOT NULL DEFAULT 0,
        shares_count INTEGER NOT NULL DEFAULT 0,
        is_liked INTEGER NOT NULL DEFAULT 0,
        is_bookmarked INTEGER NOT NULL DEFAULT 0,
        tags TEXT NOT NULL,
        image_url TEXT
      )
    ''');

    // 3. Comments Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.comments} (
        id TEXT PRIMARY KEY,
        post_id TEXT NOT NULL,
        author_name TEXT NOT NULL,
        author_avatar TEXT NOT NULL,
        author_role TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // 4. Stories Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.stories} (
        id TEXT PRIMARY KEY,
        author_name TEXT NOT NULL,
        author_avatar TEXT NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        media_url TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL DEFAULT 6,
        posted_at TEXT NOT NULL,
        is_viewed INTEGER NOT NULL DEFAULT 0,
        reaction_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 5. Groups Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.groups} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        tagline TEXT NOT NULL,
        description TEXT NOT NULL,
        banner_url TEXT NOT NULL,
        member_count INTEGER NOT NULL DEFAULT 0,
        topic TEXT NOT NULL,
        is_joined INTEGER NOT NULL DEFAULT 0,
        recent_posts_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 6. Events Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.events} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        organizer TEXT NOT NULL,
        organizer_logo TEXT NOT NULL,
        date_description TEXT NOT NULL,
        date_time TEXT NOT NULL,
        location_or_link TEXT NOT NULL,
        is_virtual INTEGER NOT NULL DEFAULT 1,
        attendee_count INTEGER NOT NULL DEFAULT 0,
        is_rsvp INTEGER NOT NULL DEFAULT 0,
        speakers TEXT NOT NULL,
        tags TEXT NOT NULL
      )
    ''');

    // 7. User Profile Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.userProfile} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        title TEXT NOT NULL,
        company TEXT NOT NULL,
        location TEXT NOT NULL,
        bio TEXT NOT NULL,
        avatar_url TEXT NOT NULL,
        is_open_to_work INTEGER NOT NULL DEFAULT 1,
        is_hiring INTEGER NOT NULL DEFAULT 0,
        skills TEXT NOT NULL,
        profile_views INTEGER NOT NULL DEFAULT 1420,
        recruiter_appearances INTEGER NOT NULL DEFAULT 380,
        ai_match_rate_boost INTEGER NOT NULL DEFAULT 30
      )
    ''');

    // 8. Experiences Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.experiences} (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        role TEXT NOT NULL,
        company TEXT NOT NULL,
        location TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_current INTEGER NOT NULL DEFAULT 0,
        description TEXT NOT NULL
      )
    ''');

    // 9. Projects Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.projects} (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        tech_stack TEXT NOT NULL,
        github_url TEXT NOT NULL,
        live_url TEXT NOT NULL
      )
    ''');

    // 10. Chat Messages Table
    await db.execute('''
      CREATE TABLE ${DatabaseTables.chatMessages} (
        id TEXT PRIMARY KEY,
        sender TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        action_chips TEXT
      )
    ''');

    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed User Profile
    await db.insert(DatabaseTables.userProfile, {
      'id': AppConstants.defaultUserId,
      'name': AppConstants.defaultUserName,
      'title': AppConstants.defaultUserRole,
      'company': AppConstants.defaultUserCompany,
      'location': AppConstants.defaultUserLocation,
      'bio': AppConstants.defaultUserBio,
      'avatar_url': AssetPaths.safeerAvatar,
      'is_open_to_work': 1,
      'is_hiring': 0,
      'skills': jsonEncode(AppConstants.defaultUserSkills),
      'profile_views': 2840,
      'recruiter_appearances': 612,
      'ai_match_rate_boost': 30,
    });

    // Seed Experiences
    await db.insert(DatabaseTables.experiences, {
      'id': 'exp_1',
      'user_id': AppConstants.defaultUserId,
      'role': 'Senior Flutter Architect & Team Lead',
      'company': 'OpenPro Labs',
      'location': 'San Francisco, CA (Remote)',
      'start_date': '2023 - Present',
      'end_date': 'Present',
      'is_current': 1,
      'description': 'Led architecture of enterprise mobile platforms, optimized memory and 120 FPS render pipelines, and implemented on-device SQLite neural matching engines.',
    });
    await db.insert(DatabaseTables.experiences, {
      'id': 'exp_2',
      'user_id': AppConstants.defaultUserId,
      'role': 'Lead Cross-Platform Mobile Engineer',
      'company': 'HyperScale Systems',
      'location': 'Seattle, WA',
      'start_date': '2021',
      'end_date': '2023',
      'is_current': 0,
      'description': 'Designed modular Clean Architecture patterns, managed a team of 9 engineers, and scaled Flutter apps to 4.2M monthly active users with 99.98% crash-free sessions.',
    });
    await db.insert(DatabaseTables.experiences, {
      'id': 'exp_3',
      'user_id': AppConstants.defaultUserId,
      'role': 'Mobile Software Engineer',
      'company': 'Apex Mobility',
      'location': 'Austin, TX',
      'start_date': '2019',
      'end_date': '2021',
      'is_current': 0,
      'description': 'Engineered native bridge integrations for Android NDK and iOS Swift frameworks, authored custom shaders, and streamlined automated CI/CD releases.',
    });

    // Seed Projects
    await db.insert(DatabaseTables.projects, {
      'id': 'proj_1',
      'user_id': AppConstants.defaultUserId,
      'title': 'OpenPro Mobile Network',
      'description': 'Production AI-powered professional network and recruiter matching platform with real-time SQLite graph mutations and adaptive master-detail views.',
      'tech_stack': jsonEncode([
        'Flutter',
        'Dart',
        'Provider',
        'SQLite',
        'fl_chart',
      ]),
      'github_url': 'https://github.com/Safeer-Hussain/openpro',
      'live_url': 'https://openpro.app',
    });
    await db.insert(DatabaseTables.projects, {
      'id': 'proj_2',
      'user_id': AppConstants.defaultUserId,
      'title': 'QuantumState Reactive Engine',
      'description': 'Zero-overhead atomic state container for high-throughput streaming dashboards with sub-millisecond dispatch times.',
      'tech_stack': jsonEncode(['Dart', 'C++ FFI', 'Reactive Streams']),
      'github_url': 'https://github.com/Safeer-Hussain/quantum-state',
      'live_url': 'https://pub.dev',
    });

    // Seed Jobs
    final sampleJobs = [
      {
        'id': 'job_101',
        'title': 'Principal Flutter Architect',
        'company': 'CloudScale Global',
        'company_logo': AssetPaths.cloudscaleLogo,
        'location': 'San Francisco, CA (Remote)',
        'workplace_type': 'Remote',
        'employment_type': 'Full-time',
        'salary_min': 195000,
        'salary_max': 245000,
        'salary_currency': 'USD',
        'equity': '0.15% - 0.35%',
        'description': 'We are seeking a Principal Flutter Architect to design our enterprise multi-tenant mobile platform. You will spearhead architectural governance, performance benchmarking, and custom rendering engine integrations.',
        'requirements': jsonEncode([
          '7+ years engineering experience, 4+ years production Flutter & Dart',
          'Demonstrated mastery in Clean Architecture and modular state machines',
          'Deep expertise with SQLite local graph querying and offline synchronization',
          'Track record mentoring senior engineers and leading platform migrations',
        ]),
        'skills': jsonEncode([
          'Flutter',
          'Dart',
          'Clean Architecture',
          'State Management (Provider)',
          'SQLite & Offline Sync',
          'System Design',
        ]),
        'posted_date': '2 hours ago',
        'is_bookmarked': 1,
        'application_status': 'none',
        'match_score': 96,
        'recruiter_name': 'Sarah Vance',
        'recruiter_title': 'VP of Technical Talent @ CloudScale',
      },
      {
        'id': 'job_102',
        'title': 'Staff AI & Mobile Systems Engineer',
        'company': 'QuantumAI Labs',
        'company_logo': AssetPaths.quantumAiLogo,
        'location': 'New York, NY (Hybrid)',
        'workplace_type': 'Hybrid',
        'employment_type': 'Full-time',
        'salary_min': 210000,
        'salary_max': 260000,
        'salary_currency': 'USD',
        'equity': '0.2% - 0.5%',
        'description': 'Architect on-device intelligence workflows integrating local LLM pipelines with high-speed Flutter UI controls. Work directly with foundational model researchers.',
        'requirements': jsonEncode([
          'Strong background in on-device AI integration and Flutter architectures',
          'Deep familiarity with streaming token APIs and state isolation',
          'Experience profiling memory consumption on low-end hardware',
        ]),
        'skills': jsonEncode([
          'Flutter',
          'AI Recruiter Matching',
          'Dart',
          'REST & GraphQL APIs',
          'Cross-Platform Performance',
        ]),
        'posted_date': '5 hours ago',
        'is_bookmarked': 0,
        'application_status': 'none',
        'match_score': 92,
        'recruiter_name': 'Marcus Thorne',
        'recruiter_title': 'Director of Engineering Recruiting',
      },
      {
        'id': 'job_103',
        'title': 'Lead FinTech Flutter Engineer',
        'company': 'FinTech Prime',
        'company_logo': AssetPaths.fintechPrimeLogo,
        'location': 'London, UK (Remote)',
        'workplace_type': 'Remote',
        'employment_type': 'Full-time',
        'salary_min': 175000,
        'salary_max': 225000,
        'salary_currency': 'USD',
        'equity': '0.1% - 0.25%',
        'description': 'Build next-generation banking interfaces with strict biometric authentication, real-time ledger synchronization, and sub-16ms chart animations.',
        'requirements': jsonEncode([
          'Experience building PCI-DSS compliant financial applications',
          'Expertise with fl_chart, custom painters, and animated transitions',
          'Strong unit and integration test coverage discipline',
        ]),
        'skills': jsonEncode([
          'Flutter',
          'Dart',
          'Clean Architecture',
          'CI/CD Pipelines',
          'REST & GraphQL APIs',
        ]),
        'posted_date': '1 day ago',
        'is_bookmarked': 0,
        'application_status': 'none',
        'match_score': 88,
        'recruiter_name': 'Elena Rostova',
        'recruiter_title': 'Lead Talent Partner',
      },
      {
        'id': 'job_104',
        'title': 'Senior Mobile DevOps & Release Architect',
        'company': 'CyberCore Infrastructure',
        'company_logo': AssetPaths.cybercoreLogo,
        'location': 'Austin, TX (Remote)',
        'workplace_type': 'Remote',
        'employment_type': 'Contract / Full-time',
        'salary_min': 160000,
        'salary_max': 200000,
        'salary_currency': 'USD',
        'equity': '0.05% - 0.15%',
        'description': 'Design hermetic CI/CD pipelines, automated snapshot testing matrices, and binary size optimization tools across Android and iOS release targets.',
        'requirements': jsonEncode([
          'Deep knowledge of GitHub Actions, Fastlane, and Gradle build pipelines',
          'Automated flutter analyze and coverage gates enforcement',
          'Experience with code signing security and key vault rotations',
        ]),
        'skills': jsonEncode([
          'CI/CD Pipelines',
          'Flutter',
          'System Design',
          'Cross-Platform Performance',
        ]),
        'posted_date': '2 days ago',
        'is_bookmarked': 0,
        'application_status': 'none',
        'match_score': 84,
        'recruiter_name': 'David Chen',
        'recruiter_title': 'Staff Technical Recruiter',
      },
      {
        'id': 'job_105',
        'title': 'HealthTech Senior Flutter Specialist',
        'company': 'HealthFlow Telehealth',
        'company_logo': AssetPaths.healthflowLogo,
        'location': 'Boston, MA (On-Site)',
        'workplace_type': 'On-Site',
        'employment_type': 'Full-time',
        'salary_min': 155000,
        'salary_max': 190000,
        'salary_currency': 'USD',
        'equity': '0.08% - 0.18%',
        'description': 'Develop HIPAA-compliant patient diagnostics and real-time medical sensor graphing dashboards in Flutter.',
        'requirements': jsonEncode([
          'Experience interfacing Bluetooth Low Energy (BLE) health devices',
          'Mastery in high-throughput data streams and reactive UI widgets',
          'Experience building accessible UI following WCAG 2.1 AA standards',
        ]),
        'skills': jsonEncode([
          'Flutter',
          'Dart',
          'SQLite & Offline Sync',
          'REST & GraphQL APIs',
        ]),
        'posted_date': '3 days ago',
        'is_bookmarked': 0,
        'application_status': 'none',
        'match_score': 79,
        'recruiter_name': 'Jessica Miller',
        'recruiter_title': 'Head of Engineering Talent',
      },
    ];

    for (final job in sampleJobs) {
      await db.insert(DatabaseTables.jobs, job);
    }

    // Seed Posts
    final samplePosts = [
      {
        'id': 'post_201',
        'author_name': 'Safeer Hussain',
        'author_role': 'Senior Flutter Architect',
        'author_avatar': AssetPaths.safeerAvatar,
        'author_company': 'OpenPro Labs',
        'content': 'Eliminating unnecessary widget rebuilds in complex data grids is critical. Here is our pattern using selector-driven state slicing in Provider combined with memoized layout passes.',
        'code_snippet':
            '''// Selective state projection prevents unneeded frame drops
Selector<JobFeedProvider, bool>(
  selector: (_, p) => p.isBookmarked(jobId),
  builder: (context, isSaved, child) {
    return BookmarkButton(isSaved: isSaved, onToggle: () => ...);
  },
);''',
        'code_language': 'dart',
        'timestamp': '18m ago',
        'likes_count': 42,
        'comments_count': 6,
        'shares_count': 11,
        'is_liked': 1,
        'is_bookmarked': 1,
        'tags': jsonEncode([
          '#Flutter',
          '#StateManagement',
          '#Performance',
          '#Architecture',
        ]),
        'image_url': null,
      },
      {
        'id': 'post_202',
        'author_name': 'Elena Rostova',
        'author_role': 'Principal Mobile Lead',
        'author_avatar': AssetPaths.fintechPrimeLogo,
        'author_company': 'FinTech Prime',
        'content': 'Offline-first SQLite career graphs with immediate optimistic mutations completely transform mobile responsiveness. When a user bookmarks a role, save index state and notify listeners in under 4ms.',
        'code_snippet': null,
        'code_language': null,
        'timestamp': '2h ago',
        'likes_count': 89,
        'comments_count': 14,
        'shares_count': 23,
        'is_liked': 0,
        'is_bookmarked': 0,
        'tags': jsonEncode(['#SQLite', '#MobileArchitecture', '#OfflineFirst']),
        'image_url': null,
      },
      {
        'id': 'post_203',
        'author_name': 'Marcus Thorne',
        'author_role': 'Director of Engineering',
        'author_avatar': AssetPaths.quantumAiLogo,
        'author_company': 'QuantumAI Labs',
        'content': 'We benchmarked AI recruiter match accuracy: embedding candidate skill ontologies directly against verified repo contributions yields a 30% jump in interview conversion rates.',
        'code_snippet': '''final matchScore = MatchCalculator.calculateScore(
  candidateSkills: profile.skills,
  candidateTitle: profile.title,
  jobSkills: job.skills,
  jobTitle: job.title,
  workplaceType: job.workplaceType,
);''',
        'code_language': 'dart',
        'timestamp': '5h ago',
        'likes_count': 134,
        'comments_count': 21,
        'shares_count': 45,
        'is_liked': 0,
        'is_bookmarked': 0,
        'tags': jsonEncode([
          '#RecruiterTech',
          '#AIMatching',
          '#HiringEfficiency',
        ]),
        'image_url': null,
      },
    ];

    for (final post in samplePosts) {
      await db.insert(DatabaseTables.posts, post);
    }

    // Seed Comments
    final sampleComments = [
      {
        'id': 'com_1',
        'post_id': 'post_201',
        'author_name': 'Elena Rostova',
        'author_avatar': AssetPaths.fintechPrimeLogo,
        'author_role': 'Principal Mobile Lead',
        'content': 'Selector is significantly cleaner than rebuilding the entire tree. Great pattern!',
        'timestamp': '12m ago',
      },
      {
        'id': 'com_2',
        'post_id': 'post_201',
        'author_name': 'Marcus Thorne',
        'author_avatar': AssetPaths.quantumAiLogo,
        'author_role': 'Director of Engineering',
        'content': 'Do you pair this with custom value comparators for deep list changes?',
        'timestamp': '8m ago',
      },
    ];

    for (final comment in sampleComments) {
      await db.insert(DatabaseTables.comments, comment);
    }

    // Seed Stories
    final sampleStories = [
      {
        'id': 'story_1',
        'author_name': 'Safeer Hussain',
        'author_avatar': AssetPaths.safeerAvatar,
        'title': 'Flutter 3.47 Architecture',
        'subtitle': 'Zero-jank 120 FPS render loops and memory safety',
        'media_url': AssetPaths.storyFlutter,
        'duration_seconds': 6,
        'posted_at': '1h ago',
        'is_viewed': 0,
        'reaction_count': 28,
      },
      {
        'id': 'story_2',
        'author_name': 'QuantumAI Labs',
        'author_avatar': AssetPaths.quantumAiLogo,
        'title': 'AI Recruiter Engine',
        'subtitle': 'Benchmarking 30% match boost with skill graphs',
        'media_url': AssetPaths.storyAi,
        'duration_seconds': 6,
        'posted_at': '3h ago',
        'is_viewed': 0,
        'reaction_count': 45,
      },
      {
        'id': 'story_3',
        'author_name': 'CyberCore Infra',
        'author_avatar': AssetPaths.cybercoreLogo,
        'title': 'CI/CD Pipeline Mastery',
        'subtitle': 'Hermetic Flutter test gates running in 90 seconds',
        'media_url': AssetPaths.storyDevops,
        'duration_seconds': 6,
        'posted_at': '6h ago',
        'is_viewed': 0,
        'reaction_count': 19,
      },
      {
        'id': 'story_4',
        'author_name': 'CloudScale Global',
        'author_avatar': AssetPaths.cloudscaleLogo,
        'title': 'We Are Hiring!',
        'subtitle': '3x Senior & Principal Mobile roles open worldwide',
        'media_url': AssetPaths.storyHiring,
        'duration_seconds': 6,
        'posted_at': '12h ago',
        'is_viewed': 0,
        'reaction_count': 64,
      },
      {
        'id': 'story_5',
        'author_name': 'FinTech Prime',
        'author_avatar': AssetPaths.fintechPrimeLogo,
        'title': 'Architecture Milestone',
        'subtitle': '4.2M users on our offline-first core with zero downtime',
        'media_url': AssetPaths.storyMilestone,
        'duration_seconds': 6,
        'posted_at': '1d ago',
        'is_viewed': 0,
        'reaction_count': 82,
      },
    ];

    for (final story in sampleStories) {
      await db.insert(DatabaseTables.stories, story);
    }

    // Seed Groups
    final sampleGroups = [
      {
        'id': 'grp_1',
        'name': 'Flutter & Native SDK Architects',
        'tagline': 'High-performance cross-platform system design',
        'description': 'Dedicated community of Principal Engineers and Mobile Architects discussing runtime internals, custom engine patches, and enterprise Clean Architecture.',
        'banner_url': AssetPaths.flutterArchitectsCover,
        'member_count': 12480,
        'topic': 'Flutter & Mobile SDKs',
        'is_joined': 1,
        'recent_posts_count': 142,
      },
      {
        'id': 'grp_2',
        'name': 'Applied AI & LLM Systems',
        'tagline': 'On-device intelligence and neural graph architectures',
        'description': 'Exploring the frontier of edge AI, token streaming optimizations, vector index quantization, and recruiter matching algorithms.',
        'banner_url': AssetPaths.aiLlmCover,
        'member_count': 9820,
        'topic': 'Artificial Intelligence',
        'is_joined': 1,
        'recent_posts_count': 98,
      },
      {
        'id': 'grp_3',
        'name': 'AWS & Cloud DevOps Guild',
        'tagline': 'Zero-downtime infrastructure and hermetic build matrices',
        'description': 'Best practices for mobile CI/CD pipelines, automated canary deployments, and container orchestration.',
        'banner_url': AssetPaths.cloudDevopsCover,
        'member_count': 7430,
        'topic': 'Cloud & DevOps',
        'is_joined': 0,
        'recent_posts_count': 65,
      },
      {
        'id': 'grp_4',
        'name': 'FinTech Leaders & Engineering VPs',
        'tagline': 'Financial safety, cryptographic ledgers, and scale',
        'description': 'Executive leadership forum for fintech technical directors managing high-throughput transaction systems.',
        'banner_url': AssetPaths.fintechLeadersCover,
        'member_count': 5120,
        'topic': 'FinTech & Leadership',
        'is_joined': 0,
        'recent_posts_count': 43,
      },
    ];

    for (final group in sampleGroups) {
      await db.insert(DatabaseTables.groups, group);
    }

    // Seed Events
    final sampleEvents = [
      {
        'id': 'evt_1',
        'title': 'Global Flutter Architecture Summit 2026',
        'organizer': 'OpenPro Engineering Hub',
        'organizer_logo': AssetPaths.techcorpLogo,
        'date_description': 'Thursday, Nov 12 • 10:00 AM PST',
        'date_time': '2026-11-12T10:00:00Z',
        'location_or_link': 'Virtual Mainstage (High-Def Stream)',
        'is_virtual': 1,
        'attendee_count': 1850,
        'is_rsvp': 1,
        'speakers': jsonEncode([
          'Safeer Hussain (Principal Architect)',
          'Marcus Thorne (Director AI Systems)',
        ]),
        'tags': jsonEncode(['#Architecture', '#Flutter', '#Performance']),
      },
      {
        'id': 'evt_2',
        'title': 'Recruiter-Talent AI Matching Masterclass',
        'organizer': 'QuantumAI Labs',
        'organizer_logo': AssetPaths.quantumAiLogo,
        'date_description': 'Tuesday, Nov 17 • 1:00 PM EST',
        'date_time': '2026-11-17T13:00:00Z',
        'location_or_link': 'Virtual Roundtable',
        'is_virtual': 1,
        'attendee_count': 940,
        'is_rsvp': 0,
        'speakers': jsonEncode([
          'Elena Rostova (VP Talent Science)',
          'Dr. Alan Vance (Lead ML Scientist)',
        ]),
        'tags': jsonEncode(['#TalentMatching', '#AI', '#CareerGrowth']),
      },
      {
        'id': 'evt_3',
        'title': 'San Francisco Executive Tech Mixer',
        'organizer': 'CloudScale Global',
        'organizer_logo': AssetPaths.cloudscaleLogo,
        'date_description': 'Saturday, Nov 21 • 6:30 PM PST',
        'date_time': '2026-11-21T18:30:00Z',
        'location_or_link': 'CloudScale Innovation Pavilion, SF',
        'is_virtual': 0,
        'attendee_count': 320,
        'is_rsvp': 0,
        'speakers': jsonEncode([
          'Sarah Vance (VP Technical Talent)',
          'David Chen (Staff Architect)',
        ]),
        'tags': jsonEncode(['#Networking', '#SanFrancisco', '#Executive']),
      },
    ];

    for (final event in sampleEvents) {
      await db.insert(DatabaseTables.events, event);
    }

    // Seed Initial AI Chat Welcome
    await db.insert(DatabaseTables.chatMessages, {
      'id': 'msg_init',
      'sender': 'assistant',
      'content': 'Welcome Safeer. I am your OpenPro Career Assistant. I have indexed your skills, career history, and active job applications from your local graph. How can I assist your career progression today?',
      'timestamp': 'Just now',
      'action_chips': jsonEncode([
        'Analyze My Match for Senior Flutter Roles',
        'Generate Tailored Cover Pitch',
        'Identify High-Paying Skill Gaps',
        'Simulate Technical Interview Question',
      ]),
    });

    await _seedSkillEndorsements(db);
  }

  Future<void> _seedSkillEndorsements(Database db) async {
    final endorsements = [
      {
        'id': 'end_1',
        'user_id': AppConstants.defaultUserId,
        'skill_name': 'Flutter & Dart Architecture',
        'endorser_name': 'Alex Rivera',
        'endorser_title': 'Staff Mobile Architect @ TechCorp Labs',
        'endorser_avatar': AssetPaths.techcorpLogo,
        'created_at': '2 days ago',
        'is_endorsed_by_me': 0,
      },
      {
        'id': 'end_2',
        'user_id': AppConstants.defaultUserId,
        'skill_name': 'Flutter & Dart Architecture',
        'endorser_name': 'Sarah Chen',
        'endorser_title': 'Principal Systems Engineer @ CloudScale',
        'endorser_avatar': AssetPaths.cloudscaleLogo,
        'created_at': '3 days ago',
        'is_endorsed_by_me': 0,
      },
      {
        'id': 'end_3',
        'user_id': AppConstants.defaultUserId,
        'skill_name': 'Flutter & Dart Architecture',
        'endorser_name': 'Marcus Vance',
        'endorser_title': 'VP Engineering @ FinTech Prime',
        'endorser_avatar': AssetPaths.fintechPrimeLogo,
        'created_at': '1 week ago',
        'is_endorsed_by_me': 0,
      },
      {
        'id': 'end_4',
        'user_id': AppConstants.defaultUserId,
        'skill_name': 'Clean Architecture & SOLID',
        'endorser_name': 'Dr. Aris Thorne',
        'endorser_title': 'Chief AI Scientist @ QuantumAI Labs',
        'endorser_avatar': AssetPaths.quantumAiLogo,
        'created_at': '4 days ago',
        'is_endorsed_by_me': 0,
      },
      {
        'id': 'end_5',
        'user_id': AppConstants.defaultUserId,
        'skill_name': 'Clean Architecture & SOLID',
        'endorser_name': 'Liam Sterling',
        'endorser_title': 'Cloud DevOps Lead @ HealthFlow',
        'endorser_avatar': AssetPaths.healthflowLogo,
        'created_at': '5 days ago',
        'is_endorsed_by_me': 0,
      },
      {
        'id': 'end_6',
        'user_id': AppConstants.defaultUserId,
        'skill_name': 'State Management (Provider/Riverpod)',
        'endorser_name': 'Sarah Chen',
        'endorser_title': 'Principal Systems Engineer @ CloudScale',
        'endorser_avatar': AssetPaths.cloudscaleLogo,
        'created_at': '1 week ago',
        'is_endorsed_by_me': 0,
      },
      {
        'id': 'end_7',
        'user_id': AppConstants.defaultUserId,
        'skill_name': 'High-Performance Concurrency',
        'endorser_name': 'Alex Rivera',
        'endorser_title': 'Staff Mobile Architect @ TechCorp Labs',
        'endorser_avatar': AssetPaths.techcorpLogo,
        'created_at': '2 weeks ago',
        'is_endorsed_by_me': 0,
      },
      {
        'id': 'end_8',
        'user_id': AppConstants.defaultUserId,
        'skill_name': 'Offline-First SQLite Systems',
        'endorser_name': 'Marcus Vance',
        'endorser_title': 'VP Engineering @ FinTech Prime',
        'endorser_avatar': AssetPaths.fintechPrimeLogo,
        'created_at': '3 days ago',
        'is_endorsed_by_me': 0,
      },
    ];

    for (final e in endorsements) {
      await db.insert(DatabaseTables.skillEndorsements, e);
    }
  }

  Future<void> resetDatabase() async {
    final db = await database;
    await db.delete(DatabaseTables.jobs);
    await db.delete(DatabaseTables.posts);
    await db.delete(DatabaseTables.comments);
    await db.delete(DatabaseTables.stories);
    await db.delete(DatabaseTables.groups);
    await db.delete(DatabaseTables.events);
    await db.delete(DatabaseTables.userProfile);
    await db.delete(DatabaseTables.experiences);
    await db.delete(DatabaseTables.projects);
    await db.delete(DatabaseTables.chatMessages);
    await db.delete(DatabaseTables.skillEndorsements);
    await db.delete(DatabaseTables.applications);
    await _seedInitialData(db);
  }
}
