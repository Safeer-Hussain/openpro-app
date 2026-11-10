class AppConstants {
  static const String appName = 'OpenPro';
  static const String appTagline = 'Next-Gen AI Professional Network';
  static const String appVersion = '1.0.0+1';

  // Seeded Profile Constants
  static const String defaultUserId = 'usr_safeer_001';
  static const String defaultUserName = 'Safeer Hussain';
  static const String defaultUserRole =
      'Senior Flutter Architect & Mobile Team Lead';
  static const String defaultUserCompany = 'OpenPro Labs';
  static const String defaultUserLocation =
      'San Francisco, CA (Open to Worldwide Remote)';
  static const String defaultUserBio =
      'Principal Mobile Architect building resilient, high-scale cross-platform systems. Specialist in Flutter runtime performance, offline-first SQLite architectures, and AI-driven recruiter matching engines.';

  static const List<String> defaultUserSkills = [
    'Flutter',
    'Dart',
    'Clean Architecture',
    'State Management (Provider)',
    'SQLite & Offline Sync',
    'AI Recruiter Matching',
    'CI/CD Pipelines',
    'System Design',
    'Cross-Platform Performance',
    'REST & GraphQL APIs',
  ];

  // Storage Keys
  static const String prefThemeMode = 'openpro_theme_mode';
  static const String prefSimulatedLatencyMs = 'openpro_sim_latency_ms';
  static const String prefSimulateError503 = 'openpro_sim_error_503';
  static const String prefDatabaseSeeded = 'openpro_db_seeded_v1';
}
