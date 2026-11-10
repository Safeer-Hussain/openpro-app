import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/repositories/ai_assistant_repository.dart';
import '../../../domain/entities/chat_message_entity.dart';

class AiAssistantViewModel extends ChangeNotifier {
  final AiAssistantRepository repository;

  List<ChatMessageEntity> _messages = [];
  bool _isLoading = true;
  bool _isStreaming = false;
  String _transientStatus = '';
  String _currentStreamingText = '';

  static const List<String> defaultActionChips = [
    'Analyze My Match for Senior Flutter Roles',
    'Generate Tailored Cover Pitch',
    'Identify High-Paying Skill Gaps',
    'Simulate Technical Interview Question',
  ];

  AiAssistantViewModel({required this.repository}) {
    loadMessages();
  }

  List<ChatMessageEntity> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isStreaming => _isStreaming;
  String get transientStatus => _transientStatus;
  String get currentStreamingText => _currentStreamingText;

  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();
    try {
      _messages = await repository.getMessages();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || _isStreaming) return;

    final userMsg = ChatMessageEntity(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'user',
      content: cleanText,
      timestamp: 'Just now',
    );

    _messages.add(userMsg);
    notifyListeners();

    try {
      await repository.saveMessage(userMsg);
    } catch (_) {}

    await _generateStreamingAiResponse(cleanText);
  }

  Future<void> _generateStreamingAiResponse(String prompt) async {
    _isStreaming = true;
    _transientStatus = 'Analyzing skill graph & recruiter criteria...';
    _currentStreamingText = '';
    notifyListeners();

    try {
      // Simulate transient analysis delay
      await Future.delayed(const Duration(milliseconds: 350));
      _transientStatus = '';
      notifyListeners();

      final stream = repository.streamResponse(prompt);
      await for (final token in stream) {
        _currentStreamingText += token;
        notifyListeners();
      }

      final assistantMsg = ChatMessageEntity(
        id: 'msg_ai_${DateTime.now().millisecondsSinceEpoch}',
        sender: 'assistant',
        content: _currentStreamingText,
        timestamp: 'Just now',
        actionChips: defaultActionChips,
      );

      _messages.add(assistantMsg);
      _currentStreamingText = '';
      try {
        await repository.saveMessage(assistantMsg);
      } catch (_) {}
    } catch (e) {
      final errorMsg = ChatMessageEntity(
        id: 'msg_err_${DateTime.now().millisecondsSinceEpoch}',
        sender: 'assistant',
        content: 'Unable to stream response at this time. Please retry.',
        timestamp: 'Just now',
      );
      _messages.add(errorMsg);
    } finally {
      // Guaranteed stream cleanup
      _isStreaming = false;
      _transientStatus = '';
      _currentStreamingText = '';
      notifyListeners();
    }
  }

  Future<void> clearChat() async {
    _messages.clear();
    _currentStreamingText = '';
    _isStreaming = false;
    _transientStatus = '';
    notifyListeners();

    try {
      await repository.clearMessages();
    } catch (_) {}
  }
}
