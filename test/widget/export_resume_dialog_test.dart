import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/core/theme/app_theme.dart';
import 'package:open_pro/domain/entities/skill_endorsement.dart';
import 'package:open_pro/domain/entities/user_profile_entity.dart';
import 'package:open_pro/presentation/profile/widgets/export_resume_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleProfile = UserProfileEntity(
    id: 'user_safeer',
    name: 'Safeer Hussain',
    title: 'Principal Mobile Systems Architect',
    company: 'CloudScale Global',
    location: 'San Francisco, CA (Remote)',
    bio: 'Staff-level Mobile Architect specializing in offline SQLite sync and high-concurrency systems.',
    avatarUrl: 'assets/images/safeer_avatar.png',
    isOpenToWork: true,
    isHiring: false,
    skills: ['Flutter & Dart Architecture', 'Offline SQLite Sync'],
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
        description: 'Engineered distributed offline SQLite sync engine.',
      ),
    ],
    projects: [
      ProjectEntity(
        id: 'proj_1',
        userId: 'user_safeer',
        title: 'OpenPro Mobile Network',
        description: 'Next-generation talent matching platform.',
        techStack: ['Flutter', 'Dart', 'SQLite'],
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
  ];

  late Directory tempDir;
  String? mockClipboardText;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('widget_resume_test_');
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
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  Widget buildDialogTestWidget() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: ExportResumeDialog(
          profile: sampleProfile,
          endorsements: sampleEndorsements,
          targetDirectory: tempDir,
        ),
      ),
    );
  }

  group('ExportResumeDialog Widget Tests', () {
    testWidgets(
      'Renders dialog header, format tabs, and default Markdown preview',
      (tester) async {
        await tester.pumpWidget(buildDialogTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Executive Resume Exporter'), findsOneWidget);
        expect(find.text('Executive Markdown (.md)'), findsOneWidget);
        expect(find.text('Clean ASCII Text (.txt)'), findsOneWidget);
        expect(find.text('Markdown Output Preview'), findsOneWidget);

        // Verify serialized content in SelectableText
        expect(find.textContaining('# Safeer Hussain'), findsOneWidget);
        expect(
          find.textContaining('Principal Mobile Systems Architect'),
          findsWidgets,
        );
      },
    );

    testWidgets('Switching to Plain Text updates the document preview', (
      tester,
    ) async {
      await tester.pumpWidget(buildDialogTestWidget());
      await tester.pumpAndSettle();

      // Tap ASCII Text format tab
      await tester.tap(find.text('Clean ASCII Text (.txt)'));
      await tester.pumpAndSettle();

      expect(find.text('ASCII Document Preview'), findsOneWidget);
      expect(find.textContaining('SAFEER HUSSAIN'), findsOneWidget);
      expect(find.textContaining('EXECUTIVE SUMMARY'), findsOneWidget);
    });

    testWidgets(
      'Copy to Clipboard triggers clipboard write and success snackbar',
      (tester) async {
        await tester.pumpWidget(buildDialogTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Copy to Clipboard'));
        await tester.pumpAndSettle();

        expect(
          find.text('Executive resume copied to clipboard.'),
          findsOneWidget,
        );

        final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
        expect(clipboardData?.text, contains('# Safeer Hussain'));
      },
    );

    testWidgets(
      'Save File button writes file to disk and displays success toast',
      (tester) async {
        await tester.pumpWidget(buildDialogTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Save File'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Resume exported successfully:'),
          findsOneWidget,
        );

        final files = tempDir.listSync();
        expect(files.isNotEmpty, isTrue);
        expect(files.first.path.endsWith('.md'), isTrue);
      },
    );

    testWidgets('Zero RenderFlex overflow on 800x360 landscape viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildDialogTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(ExportResumeDialog), findsOneWidget);
    });
  });
}
