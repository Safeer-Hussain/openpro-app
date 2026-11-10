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
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_repositories.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    if (!sl.isRegistered<LocalNotificationService>()) {
      sl.registerSingleton<LocalNotificationService>(
        LocalNotificationService(),
      );
    }
  });

  Widget buildLandscapeApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => JobFeedViewModel(repository: MockJobRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SocialFeedViewModel(repository: MockSocialRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AiAssistantViewModel(repository: MockAiAssistantRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CommunityViewModel(repository: MockCommunityRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(repository: MockProfileRepository()),
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

  testWidgets('Zero RenderFlex overflow errors on 800x360 landscape viewport', (
    tester,
  ) async {
    // Set 800x360 landscape phone resolution
    tester.view.physicalSize = const Size(800, 360);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildLandscapeApp());
    await tester.pumpAndSettle();

    // Verify NavigationRail is active in landscape instead of BottomNavigationBar
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    // Verify master-detail layout on Job Feed
    expect(tester.takeException(), isNull);

    // Switch to Profile Tab
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byIcon(Icons.person_outline_rounded),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Switch to Community Tab
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byIcon(Icons.hub_outlined),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Switch to Feed Tab
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byIcon(Icons.dynamic_feed_rounded),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
