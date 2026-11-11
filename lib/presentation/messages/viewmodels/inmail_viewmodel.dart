import 'package:flutter/foundation.dart';

import '../../../domain/entities/inmail_message.dart';
import '../../../domain/repositories/inmail_repository_interface.dart';

class InmailViewModel extends ChangeNotifier {
  final InmailRepositoryInterface repository;

  InmailViewModel({required this.repository}) {
    loadMessages();
  }

  static const List<String> quickReplyTemplates = [
    'Interested, let us connect',
    'Not looking, but keep in touch',
    'Decline politely',
  ];

  List<InmailMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _selectedTabIndex = 0; // 0 = Recruiter Outreach, 1 = General Messages

  List<InmailMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedTabIndex => _selectedTabIndex;

  List<InmailMessage> get recruiterMessages =>
      _messages.where((m) => m.isRecruiter).toList();

  List<InmailMessage> get generalMessages =>
      _messages.where((m) => m.isGeneral).toList();

  List<InmailMessage> get currentMessages =>
      _selectedTabIndex == 0 ? recruiterMessages : generalMessages;

  int get unreadRecruiterCount =>
      recruiterMessages.where((m) => m.isUnread).length;

  int get unreadGeneralCount => generalMessages.where((m) => m.isUnread).length;

  int get totalUnreadCount => _messages.where((m) => m.isUnread).length;

  void setTabIndex(int index) {
    if (_selectedTabIndex != index) {
      _selectedTabIndex = index;
      notifyListeners();
    }
  }

  Future<void> loadMessages() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await repository.getMessages();
    } catch (e) {
      _errorMessage = 'Failed to load InMail messages: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final current = _messages[index];
    if (current.isUnread) {
      // Optimistic local update
      _messages[index] = current.copyWith(status: 'read');
      notifyListeners();

      try {
        await repository.markAsRead(id);
      } catch (e) {
        // Revert on failure
        _messages[index] = current;
        notifyListeners();
      }
    }
  }

  Future<bool> sendReply(String id, String replyContent) async {
    final cleanContent = replyContent.trim();
    if (cleanContent.isEmpty) return false;

    final index = _messages.indexWhere((m) => m.id == id);
    if (index == -1) return false;

    final original = _messages[index];
    final optimisticReply = original.copyWith(
      status: 'replied',
      replyContent: cleanContent,
      repliedAt: 'Just now',
    );
    _messages[index] = optimisticReply;
    notifyListeners();

    try {
      final updated = await repository.sendReply(
        id: id,
        replyContent: cleanContent,
      );
      _messages[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      _messages[index] = original;
      _errorMessage = 'Failed to send reply: $e';
      notifyListeners();
      return false;
    }
  }

  InmailMessage? findMessage(String id) {
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) return _messages[index];
    return null;
  }
}
