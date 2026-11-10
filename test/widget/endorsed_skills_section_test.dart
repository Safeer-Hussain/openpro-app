import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:open_pro/core/theme/app_theme.dart';
import 'package:open_pro/presentation/profile/viewmodels/profile_viewmodel.dart';
import 'package:open_pro/presentation/profile/views/widgets/endorsed_skills_section.dart';

import '../helpers/mock_repositories.dart';

void main() {
  testWidgets(
    'EndorsedSkillsSection renders avatar stacks and reacts to endorsement tap',
    (tester) async {
      final mockProfileRepo = MockProfileRepository();
      final mockSkillRepo = MockSkillRepository();
      final viewModel = ProfileViewModel(
        repository: mockProfileRepo,
        skillRepository: mockSkillRepo,
      );

      await tester.pumpWidget(
        ChangeNotifierProvider<ProfileViewModel>.value(
          value: viewModel,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: EndorsedSkillsSection(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Peer Skill Endorsements'), findsOneWidget);
      expect(find.text('Flutter & Dart Architecture'), findsOneWidget);
      expect(find.text('Clean Architecture & SOLID'), findsOneWidget);
      expect(find.text('Endorse'), findsWidgets);
      expect(find.text('Endorsed'), findsWidgets);

      // Tap on the first "Endorse" button
      final endorseButton = find.text('Endorse').first;
      await tester.tap(endorseButton);
      await tester.pumpAndSettle();

      // Verify state transitioned immediately
      expect(viewModel.endorsements.first.isEndorsedByMe, isTrue);
    },
  );
}
