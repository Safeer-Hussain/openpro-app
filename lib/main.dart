import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/database/app_database.dart';
import 'core/network/mock_network_interceptor.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/services/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'data/repositories/ai_assistant_repository.dart';
import 'data/repositories/community_repository.dart';
import 'data/repositories/inmail_repository.dart';
import 'data/repositories/job_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/social_repository.dart';
import 'presentation/ai_assistant/viewmodels/ai_assistant_viewmodel.dart';
import 'presentation/community/viewmodels/community_viewmodel.dart';
import 'presentation/job_feed/viewmodels/job_feed_viewmodel.dart';
import 'presentation/messages/viewmodels/inmail_viewmodel.dart';
import 'presentation/profile/viewmodels/debug_settings_viewmodel.dart';
import 'presentation/profile/viewmodels/profile_viewmodel.dart';
import 'presentation/social_feed/viewmodels/social_feed_viewmodel.dart';
import 'presentation/splash/splash_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();

  runApp(const OpenProApp());
}

class OpenProApp extends StatelessWidget {
  const OpenProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => JobFeedViewModel(repository: sl<JobRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SocialFeedViewModel(repository: sl<SocialRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AiAssistantViewModel(repository: sl<AiAssistantRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CommunityViewModel(repository: sl<CommunityRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(repository: sl<ProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => InmailViewModel(repository: sl<InmailRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => DebugSettingsViewModel(
            mockInterceptor: sl<MockNetworkInterceptor>(),
            notificationService: sl<LocalNotificationService>(),
            database: sl<AppDatabase>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'OpenPro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashView(),
          );
        },
      ),
    );
  }
}
