import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/core/theme/app_theme.dart';
import 'package:open_pro/presentation/feed/widgets/markdown_post_body.dart';
import 'package:open_pro/presentation/feed/widgets/markdown_post_editor.dart';

void main() {
  group('MarkdownPostEditor and MarkdownPostBody Tests', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('Renders Edit mode with markdown toolbar and character counter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarkdownPostEditor(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('0 / 2000'), findsOneWidget);
      expect(find.byIcon(Icons.format_bold_rounded), findsOneWidget);
      expect(find.byIcon(Icons.format_italic_rounded), findsOneWidget);
      expect(find.byIcon(Icons.code_rounded), findsOneWidget);
    });

    testWidgets('Inserts markdown syntax via toolbar buttons', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarkdownPostEditor(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap bold button
      await tester.tap(find.byIcon(Icons.format_bold_rounded));
      await tester.pumpAndSettle();

      expect(controller.text, contains('**bold text**'));
      expect(find.text('${controller.text.length} / 2000'), findsOneWidget);
    });

    testWidgets('Toggles to Preview mode and renders formatted markdown elements', (tester) async {
      controller.text = '''
# Scalable State Architecture
- Reactive ChangeNotifier
- Zero boilerplate SQLite cache

```dart
final state = Provider.of<FeedViewModel>(context);
```
''';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarkdownPostEditor(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Preview tab
      await tester.tap(find.text('Preview'));
      await tester.pumpAndSettle();

      expect(find.byType(MarkdownPostBody), findsOneWidget);
      expect(find.text('Scalable State Architecture'), findsOneWidget);
      expect(find.text('DART'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });

    testWidgets('Enforces 2,000 character limit with warning banner when exceeded', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: MarkdownPostEditor(controller: controller),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Set text over 2000 characters
      controller.text = 'A' * 2050;
      await tester.pumpAndSettle();

      expect(find.text('2050 / 2000'), findsOneWidget);
      expect(find.textContaining('Character limit exceeded (maximum 2000 characters)'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('MarkdownPostBody renders inline code and hyperlinks', (tester) async {
      const sample = 'Use `Provider` with [OpenPro Docs](https://openpro.dev) for MVVM.';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: MarkdownPostBody(text: sample),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MarkdownPostBody), findsOneWidget);
      expect(find.text('Provider'), findsOneWidget);
    });
  });
}
