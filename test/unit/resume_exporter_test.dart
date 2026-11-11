import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/core/utils/resume_exporter.dart';
import 'package:open_pro/domain/entities/skill_endorsement.dart';
import 'package:open_pro/domain/entities/user_profile_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleProfile = UserProfileEntity(
    id: 'user_safeer',
    name: 'Safeer Hussain',
    title: 'Principal Mobile Systems Architect',
    company: 'CloudScale Global',
    location: 'San Francisco, CA (Remote)',
    bio: 'Staff-level Mobile Architect with 8+ years experience designing offline-first Flutter systems.',
    avatarUrl: 'assets/images/safeer_avatar.png',
    isOpenToWork: true,
    isHiring: false,
    skills: [
      'Flutter & Dart Architecture',
      'Offline SQLite Sync',
      'Clean Architecture & SOLID',
    ],
    experiences: [
      ExperienceEntity(
        id: 'exp_1',
        userId: 'user_safeer',
        role: 'Executive Staff Mobile Architect',
        company: 'CloudScale Global',
        location: 'San Francisco, CA (Remote)',
        startDate: '2023',
        endDate: 'Present',
        isCurrent: true,
        description: 'Architected distributed offline state synchronization engine handling 50k transactions/sec.',
      ),
      ExperienceEntity(
        id: 'exp_2',
        userId: 'user_safeer',
        role: 'Lead Mobile Infrastructure Engineer',
        company: 'QuantumAI Labs',
        location: 'New York, NY',
        startDate: '2021',
        endDate: '2023',
        isCurrent: false,
        description: 'Engineered real-time on-device machine learning inference client pipelines.',
      ),
    ],
    projects: [
      ProjectEntity(
        id: 'proj_1',
        userId: 'user_safeer',
        title: 'OpenPro Mobile Network',
        description: 'Next-generation professional network and talent matching platform.',
        techStack: ['Flutter', 'Dart', 'SQLite', 'Provider'],
        githubUrl: 'https://github.com/Safeer-Hussain/openpro',
        liveUrl: 'https://openpro.dev',
      ),
    ],
    profileViews: 1420,
    recruiterAppearances: 388,
    aiMatchRateBoost: 18,
  );

  const sampleEndorsements = [
    SkillEndorsement(
      skillName: 'Flutter & Dart Architecture',
      count: 14,
      isEndorsedByMe: false,
      topEndorsers: [],
    ),
    SkillEndorsement(
      skillName: 'Offline SQLite Sync',
      count: 9,
      isEndorsedByMe: true,
      topEndorsers: [],
    ),
  ];

  late ResumeExporter exporter;
  late Directory tempDir;

  setUp(() async {
    exporter = const ResumeExporter();
    tempDir = await Directory.systemTemp.createTemp('resume_test_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ResumeExporter Unit Tests', () {
    test('generateMarkdown produces structured Executive Markdown CV', () {
      final markdown = exporter.generateMarkdown(
        sampleProfile,
        endorsements: sampleEndorsements,
      );

      expect(markdown, contains('# Safeer Hussain'));
      expect(
        markdown,
        contains('**Principal Mobile Systems Architect** | CloudScale Global'),
      );
      expect(markdown, contains('## Executive Summary'));
      expect(markdown, contains(sampleProfile.bio));
      expect(markdown, contains('## Core Competencies & Technical Skills'));
      expect(
        markdown,
        contains(
          '**Flutter & Dart Architecture** (Verified: 14 peer endorsements)',
        ),
      );
      expect(
        markdown,
        contains('**Offline SQLite Sync** (Verified: 9 peer endorsements)'),
      );
      expect(markdown, contains('## Professional Experience'));
      expect(markdown, contains('### Executive Staff Mobile Architect'));
      expect(markdown, contains('**CloudScale Global** | *2023 - Present*'));
      expect(
        markdown,
        contains('## Engineering Platforms & Featured Projects'),
      );
      expect(markdown, contains('### OpenPro Mobile Network'));
      expect(
        markdown,
        contains('Repository: https://github.com/Safeer-Hussain/openpro'),
      );
      expect(markdown, contains('## Verified OpenPro Metrics'));
      expect(markdown, contains('Profile Views: 1420'));
      expect(markdown, contains('Recruiter Search Appearances: 388'));
      expect(markdown, contains('Talent Match Rate Advantage: +18%'));
    });

    test('generateMarkdown falls back to profile.skills when endorsements are omitted', () {
      final markdown = exporter.generateMarkdown(sampleProfile);

      expect(markdown, contains('- Flutter & Dart Architecture'));
      expect(markdown, contains('- Offline SQLite Sync'));
      expect(markdown, contains('- Clean Architecture & SOLID'));
    });

    test('generatePlainText produces clean ATS-ready ASCII text layout', () {
      final plainText = exporter.generatePlainText(
        sampleProfile,
        endorsements: sampleEndorsements,
      );

      expect(plainText, contains('SAFEER HUSSAIN'));
      expect(
        plainText,
        contains('Principal Mobile Systems Architect at CloudScale Global'),
      );
      expect(plainText, contains('EXECUTIVE SUMMARY'));
      expect(plainText, contains('CORE TECHNICAL SKILLS'));
      expect(plainText, contains('Flutter & Dart Architecture'));
      expect(plainText, contains('[14 Endorsements]'));
      expect(plainText, contains('PROFESSIONAL EXPERIENCE'));
      expect(plainText, contains('EXECUTIVE STAFF MOBILE ARCHITECT'));
      expect(plainText, contains('FEATURED ARCHITECTURAL PROJECTS'));
      expect(plainText, contains('OPENPRO MOBILE NETWORK'));
      expect(plainText, contains('PLATFORM BENCHMARK METRICS'));
      expect(plainText, contains('Profile Views: 1420'));
    });

    test(
      'exportResumeFile writes markdown document to target directory',
      () async {
        final file = await exporter.exportResumeFile(
          sampleProfile,
          format: 'md',
          endorsements: sampleEndorsements,
          targetDirectory: tempDir,
        );

        expect(await file.exists(), isTrue);
        expect(file.path.endsWith('.md'), isTrue);

        final content = await file.readAsString();
        expect(content, contains('# Safeer Hussain'));
        expect(content, contains('## Executive Summary'));
      },
    );

    test(
      'exportResumeFile writes plain text document to target directory',
      () async {
        final file = await exporter.exportResumeFile(
          sampleProfile,
          format: 'txt',
          endorsements: sampleEndorsements,
          targetDirectory: tempDir,
        );

        expect(await file.exists(), isTrue);
        expect(file.path.endsWith('.txt'), isTrue);

        final content = await file.readAsString();
        expect(content, contains('SAFEER HUSSAIN'));
        expect(content, contains('EXECUTIVE SUMMARY'));
      },
    );

    test('copyToClipboard puts serialized resume into Clipboard', () async {
      String? mockClipboardText;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              mockClipboardText = (call.arguments as Map?)?['text'] as String?;
              return null;
            }
            if (call.method == 'Clipboard.getData') {
              return {'text': mockClipboardText};
            }
            return null;
          });

      const textToCopy = 'Executive CV Content for Verification';
      await exporter.copyToClipboard(textToCopy);

      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      expect(clipboardData?.text, equals(textToCopy));
    });
  });
}
