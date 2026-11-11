import '../entities/inmail_message.dart';

abstract class InmailRepositoryInterface {
  Future<List<InmailMessage>> getMessages({String? category, String? userId});

  Future<InmailMessage?> getMessageById(String id);

  Future<void> markAsRead(String id);

  Future<InmailMessage> sendReply({
    required String id,
    required String replyContent,
  });

  Future<int> getUnreadCount({String? category, String? userId});
}
