import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/core/theme/app_theme.dart';
import 'package:open_pro/presentation/messages/inmail_detail_view.dart';
import 'package:open_pro/presentation/messages/inmail_inbox_view.dart';
import 'package:open_pro/presentation/messages/viewmodels/inmail_viewmodel.dart';
import 'package:provider/provider.dart';

import '../helpers/mock_repositories.dart';

void main() {
  late MockInmailRepository mockRepo;
  late InmailViewModel viewModel;

  setUp(() {
    mockRepo = MockInmailRepository();
    viewModel = InmailViewModel(repository: mockRepo);
  });

  Widget createWidgetUnderTest(Widget child) {
    return ChangeNotifierProvider<InmailViewModel>.value(
      value: viewModel,
      child: MaterialApp(theme: AppTheme.darkTheme, home: child),
    );
  }

  group('InmailInboxView Widget Tests', () {
    testWidgets(
      'Renders segmented tabs, recruiter messages, and unread badges',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(const InmailInboxView()));
        await tester.pumpAndSettle();

        expect(find.text('InMail & Messages'), findsOneWidget);
        expect(find.text('Recruiter Outreach'), findsOneWidget);
        expect(find.text('General'), findsOneWidget);

        // Default tab shows recruiter outreach messages
        expect(find.text('Elena Rostova'), findsOneWidget);
        expect(find.text('Marcus Thorne'), findsOneWidget);
        expect(find.text('Sarah Vance'), findsOneWidget);

        // General message not in tab 0
        expect(find.text('Alex Chen'), findsNothing);

        // Switch to General Tab
        await tester.tap(find.text('General'));
        await tester.pumpAndSettle();

        expect(find.text('Alex Chen'), findsOneWidget);
        expect(find.text('Elena Rostova'), findsNothing);
      },
    );

    testWidgets(
      'Tapping a message opens InmailDetailView and marks it as read',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(const InmailInboxView()));
        await tester.pumpAndSettle();

        // Tap on Elena Rostova's message card
        await tester.tap(find.text('Elena Rostova'));
        await tester.pumpAndSettle();

        // Verified on InmailDetailView
        expect(find.byType(InmailDetailView), findsOneWidget);
        expect(find.text('Recruiter InMail'), findsOneWidget);
        expect(
          find.text(
            'Executive Staff Mobile Architect - Cloud Infrastructure Platform',
          ),
          findsOneWidget,
        );
        expect(find.text('Elena Rostova'), findsOneWidget);
        expect(
          find.textContaining('Cloud Infrastructure Platform'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'Zero RenderFlex overflow on 800x360 landscape viewport for Inbox',
      (tester) async {
        tester.view.physicalSize = const Size(800, 360);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createWidgetUnderTest(const InmailInboxView()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });

  group('InmailDetailView Widget Tests', () {
    testWidgets(
      'Renders recruiter header, quick-reply chips, and sends response',
      (tester) async {
        await tester.pumpWidget(
          createWidgetUnderTest(const InmailDetailView(messageId: 'inmail_1')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Elena Rostova'), findsOneWidget);
        expect(find.text('Executive Staff Mobile Architect'), findsOneWidget);
        expect(find.text('\$210,000 - \$250,000 + Equity'), findsOneWidget);

        // Verify quick-reply action chips are displayed
        expect(find.text('Interested, let us connect'), findsOneWidget);
        expect(find.text('Not looking, but keep in touch'), findsOneWidget);
        expect(find.text('Decline politely'), findsOneWidget);

        // Tap a quick-reply chip to populate the composer
        await tester.tap(find.text('Interested, let us connect'));
        await tester.pumpAndSettle();

        // Find the TextField and verify populated text
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(
          textField.controller?.text,
          equals('Interested, let us connect'),
        );

        // Scroll to and tap Send Response button
        await tester.ensureVisible(find.text('Send Response'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Send Response'));
        await tester.pumpAndSettle();

        // Verify status transitions to Replied and banner appears
        expect(find.text('You replied to this outreach'), findsOneWidget);
        expect(find.text('Interested, let us connect'), findsWidgets);
      },
    );

    testWidgets('Displays replied banner for already answered message', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidgetUnderTest(const InmailDetailView(messageId: 'inmail_3')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sarah Vance'), findsOneWidget);
      expect(find.text('You replied to this outreach'), findsOneWidget);
      expect(find.text('Replied'), findsWidgets);
    });

    testWidgets(
      'Zero RenderFlex overflow on 800x360 landscape viewport for Detail',
      (tester) async {
        tester.view.physicalSize = const Size(800, 360);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          createWidgetUnderTest(const InmailDetailView(messageId: 'inmail_1')),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
