import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/domain/entities/inmail_message.dart';
import 'package:open_pro/presentation/messages/viewmodels/inmail_viewmodel.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('InmailMessage Entity Tests', () {
    test('Entity supports copyWith, getters, and serialization parity', () {
      const message = InmailMessage(
        id: 'msg_100',
        userId: 'user_1',
        senderName: 'Marcus Thorne',
        senderRole: 'VP Talent Science',
        senderCompany: 'QuantumAI Labs',
        senderAvatar: 'assets/images/quantum_ai.png',
        category: 'recruiter',
        subject: 'Lead AI Engineer',
        body: 'Opportunity description here.',
        opportunityTitle: 'Staff Engineer',
        opportunitySalary: '\$200k',
        status: 'unread',
        sentAt: '1 hour ago',
      );

      expect(message.isRecruiter, isTrue);
      expect(message.isGeneral, isFalse);
      expect(message.isUnread, isTrue);
      expect(message.isRead, isFalse);
      expect(message.isReplied, isFalse);

      final map = message.toMap();
      expect(map['id'], equals('msg_100'));
      expect(map['category'], equals('recruiter'));
      expect(map['status'], equals('unread'));

      final fromMap = InmailMessage.fromMap(map);
      expect(fromMap.id, equals(message.id));
      expect(fromMap.senderName, equals(message.senderName));
      expect(fromMap.opportunitySalary, equals('\$200k'));

      final updated = message.copyWith(
        status: 'replied',
        replyContent: 'Interested, let us connect',
        repliedAt: 'Just now',
      );
      expect(updated.status, equals('replied'));
      expect(updated.isReplied, isTrue);
      expect(updated.isUnread, isFalse);
      expect(updated.replyContent, equals('Interested, let us connect'));
      expect(message.status, equals('unread')); // Immutability check
    });
  });

  group('InmailViewModel Unit Tests', () {
    late MockInmailRepository mockRepo;
    late InmailViewModel viewModel;

    setUp(() {
      mockRepo = MockInmailRepository();
      viewModel = InmailViewModel(repository: mockRepo);
    });

    test(
      'Loads messages and computes category-separated inbox lists',
      () async {
        await viewModel.loadMessages();

        expect(viewModel.messages.length, equals(4));
        expect(viewModel.recruiterMessages.length, equals(3));
        expect(viewModel.generalMessages.length, equals(1));
        expect(
          viewModel.currentMessages.length,
          equals(3),
        ); // Default tab 0 = recruiter
      },
    );

    test('Computes unread metrics correctly across categories', () async {
      await viewModel.loadMessages();

      // Recruiter: inmail_1 is unread, inmail_2 is read, inmail_3 is replied
      expect(viewModel.unreadRecruiterCount, equals(1));
      // General: inmail_4 is unread
      expect(viewModel.unreadGeneralCount, equals(1));
      // Total unread
      expect(viewModel.totalUnreadCount, equals(2));
    });

    test('Switching tab updates currentMessages list', () async {
      await viewModel.loadMessages();

      expect(viewModel.selectedTabIndex, equals(0));
      expect(viewModel.currentMessages.length, equals(3));

      viewModel.setTabIndex(1);
      expect(viewModel.selectedTabIndex, equals(1));
      expect(viewModel.currentMessages.length, equals(1));
      expect(viewModel.currentMessages.first.senderName, equals('Alex Chen'));
    });

    test('Exposes standard quick-reply action templates', () {
      expect(InmailViewModel.quickReplyTemplates.length, equals(3));
      expect(
        InmailViewModel.quickReplyTemplates,
        contains('Interested, let us connect'),
      );
      expect(
        InmailViewModel.quickReplyTemplates,
        contains('Not looking, but keep in touch'),
      );
      expect(InmailViewModel.quickReplyTemplates, contains('Decline politely'));
    });

    test('markAsRead transitions unread message to read', () async {
      await viewModel.loadMessages();

      final target = viewModel.findMessage('inmail_1');
      expect(target, isNotNull);
      expect(target!.status, equals('unread'));
      expect(viewModel.unreadRecruiterCount, equals(1));

      await viewModel.markAsRead('inmail_1');

      final updated = viewModel.findMessage('inmail_1');
      expect(updated!.status, equals('read'));
      expect(viewModel.unreadRecruiterCount, equals(0));
      expect(viewModel.totalUnreadCount, equals(1));
    });

    test('sendReply rejects empty response text and returns false', () async {
      await viewModel.loadMessages();

      final result = await viewModel.sendReply('inmail_1', '   ');
      expect(result, isFalse);
      expect(viewModel.findMessage('inmail_1')!.status, equals('unread'));
    });

    test(
      'sendReply updates message status to replied and records response',
      () async {
        await viewModel.loadMessages();

        const replyText =
            'Interested, let us connect. When are you free for a call?';
        final result = await viewModel.sendReply('inmail_1', replyText);

        expect(result, isTrue);
        final updated = viewModel.findMessage('inmail_1');
        expect(updated, isNotNull);
        expect(updated!.status, equals('replied'));
        expect(updated.isReplied, isTrue);
        expect(updated.replyContent, equals(replyText));
        expect(updated.repliedAt, isNotNull);
      },
    );

    test('findMessage returns null for non-existent identifier', () async {
      await viewModel.loadMessages();
      expect(viewModel.findMessage('non_existing_id'), isNull);
    });
  });
}
