import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/core/database/app_database.dart';
import 'package:open_pro/core/network/mock_network_interceptor.dart';
import 'package:open_pro/core/notifications/local_notification_service.dart';
import 'package:open_pro/core/services/service_locator.dart';
import 'package:open_pro/core/theme/app_theme.dart';
import 'package:open_pro/core/theme/theme_provider.dart';
import 'package:open_pro/presentation/adaptive_scaffold.dart';
import 'package:open_pro/presentation/ai_assistant/viewmodels/ai_assistant_viewmodel.dart';
import 'package:open_pro/presentation/community/viewmodels/community_viewmodel.dart';
import 'package:open_pro/presentation/job_feed/viewmodels/job_feed_viewmodel.dart';
import 'package:open_pro/presentation/profile/viewmodels/debug_settings_viewmodel.dart';
import 'package:open_pro/presentation/profile/viewmodels/profile_viewmodel.dart';
import 'package:open_pro/presentation/social_feed/viewmodels/social_feed_viewmodel.dart';
import 'package:provider/provider.dart';

import '../helpers/mock_repositories.dart';

void main() {
  setUp(() async {
    if (!sl.isRegistered<LocalNotificationService>()) {
      sl.registerSingleton<LocalNotificationService>(
        LocalNotificationService(),
      );
    }
  });

  Widget buildTestShell() {
    final mockJobRepo = MockJobRepository();
    final mockSocialRepo = MockSocialRepository();
    final mockAiRepo = MockAiAssistantRepository();
    final mockCommunityRepo = MockCommunityRepository();
    final mockProfileRepo = MockProfileRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => JobFeedViewModel(repository: mockJobRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => SocialFeedViewModel(repository: mockSocialRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => AiAssistantViewModel(repository: mockAiRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityViewModel(repository: mockCommunityRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(repository: mockProfileRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => DebugSettingsViewModel(
            mockInterceptor: MockNetworkInterceptor(),
            notificationService: sl<LocalNotificationService>(),
            database: AppDatabase.instance,
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: const AdaptiveScaffold(),
      ),
    );
  }

  testWidgets('Zero duplicate Hero tag exceptions across multi-tab shell', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestShell());
    await tester.pumpAndSettle();

    // Tab 0: Jobs (fab_job_feed)
    expect(find.byType(AdaptiveScaffold), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    FloatingActionButton fab = tester.widget(find.byType(FloatingActionButton));
    expect(fab.heroTag, equals('fab_job_feed'));

    // Switch to Tab 1: Feed (fab_create_post)
    await tester.tap(find.text('Feed'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);
    fab = tester.widget(find.byType(FloatingActionButton));
    expect(fab.heroTag, equals('fab_create_post'));

    // Switch to Tab 2: AI Match (No FAB)
    await tester.tap(find.text('AI Match'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsNothing);

    // Switch to Tab 3: Community (fab_groups_create)
    await tester.tap(find.text('Community'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);
    fab = tester.widget(find.byType(FloatingActionButton));
    expect(fab.heroTag, equals('fab_groups_create'));

    // Switch to Tab 4: Profile (fab_profile_edit)
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);
    fab = tester.widget(find.byType(FloatingActionButton));
    expect(fab.heroTag, equals('fab_profile_edit'));

    // Return to Tab 0 with zero scheduler or hero collision exceptions
    await tester.tap(find.text('Jobs'));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);
    fab = tester.widget(find.byType(FloatingActionButton));
    expect(fab.heroTag, equals('fab_job_feed'));
  });
}
