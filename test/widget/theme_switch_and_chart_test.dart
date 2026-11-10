import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/core/theme/app_theme.dart';
import 'package:open_pro/core/theme/theme_provider.dart';
import 'package:open_pro/presentation/profile/viewmodels/profile_viewmodel.dart';
import 'package:open_pro/presentation/profile/views/profile_view.dart';
import 'package:open_pro/presentation/profile/views/widgets/recruiter_analytics_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_repositories.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Full-width chart rendering and instant Dark/Light theme switching',
    (tester) async {
      final themeProvider = ThemeProvider();
      final profileViewModel = ProfileViewModel(
        repository: MockProfileRepository(),
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: themeProvider),
            ChangeNotifierProvider.value(value: profileViewModel),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, tp, _) {
              return MaterialApp(
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: tp.themeMode,
                home: const Scaffold(body: ProfileView()),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Recruiter Analytics Card & LineChart are rendered
      expect(find.byType(RecruiterAnalyticsCard), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);

      // Initial theme is Dark
      expect(themeProvider.isDarkMode, isTrue);

      // Toggle theme to Light mode
      await themeProvider.setThemeMode(ThemeMode.light);
      await tester.pumpAndSettle();
      expect(themeProvider.isDarkMode, isFalse);

      // Verify chart still renders cleanly with light mode colorScheme
      expect(find.byType(LineChart), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Toggle theme back to Dark mode
      await themeProvider.setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(themeProvider.isDarkMode, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
