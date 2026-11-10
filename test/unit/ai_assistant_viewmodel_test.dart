import 'package:flutter_test/flutter_test.dart';
import 'package:open_pro/presentation/ai_assistant/viewmodels/ai_assistant_viewmodel.dart';

import '../helpers/mock_repositories.dart';

void main() {
  group('AiAssistantViewModel Unit Tests', () {
    late MockAiAssistantRepository mockRepo;
    late AiAssistantViewModel viewModel;

    setUp(() {
      mockRepo = MockAiAssistantRepository();
      viewModel = AiAssistantViewModel(repository: mockRepo);
    });

    test('Initializes with empty or loaded chat messages', () async {
      await viewModel.loadMessages();
      expect(viewModel.isStreaming, isFalse);
      expect(viewModel.messages, isEmpty);
    });

    test('Guarantees isStreaming resets to false on message completion in finally block', () async {
      await viewModel.loadMessages();

      final future = viewModel.sendMessage(
        'Analyze My Match for Senior Flutter Roles',
      );
      // While awaiting, verify it processes and finishes with isStreaming == false
      await future;

      expect(viewModel.isStreaming, isFalse);
      expect(viewModel.transientStatus, isEmpty);
      expect(viewModel.messages.length, equals(2));
      expect(viewModel.messages.first.isUser, isTrue);
      expect(viewModel.messages.last.isUser, isFalse);
      expect(viewModel.messages.last.content, contains('match'));
    });

    test('clearChat removes all conversation records and resets streaming indicators', () async {
      await viewModel.sendMessage('Quick query');
      expect(viewModel.messages.isNotEmpty, isTrue);

      await viewModel.clearChat();
      expect(viewModel.messages, isEmpty);
      expect(viewModel.isStreaming, isFalse);
    });
  });
}
