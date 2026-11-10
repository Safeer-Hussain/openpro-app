import 'dart:async';

class RecruiterNotification {
  final String id;
  final String title;
  final String body;
  final String company;
  final int matchScore;
  final DateTime timestamp;

  RecruiterNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.company,
    required this.matchScore,
    required this.timestamp,
  });
}

class LocalNotificationService {
  final _controller = StreamController<RecruiterNotification>.broadcast();
  final List<RecruiterNotification> _notifications = [];

  Stream<RecruiterNotification> get notificationStream => _controller.stream;
  List<RecruiterNotification> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _notifications.length;

  void triggerRecruiterMatch({String? company, String? role, int? matchScore}) {
    final comp = company ?? 'CloudScale Global';
    final r = role ?? 'Principal Flutter Architect';
    final score = matchScore ?? 96;

    final notif = RecruiterNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Recruiter Match ($score% Compatibility)',
      body: '$comp recruiter Sarah Vance viewed your verified skills for $r.',
      company: comp,
      matchScore: score,
      timestamp: DateTime.now(),
    );

    _notifications.insert(0, notif);
    _controller.add(notif);
  }

  void clearNotifications() {
    _notifications.clear();
  }

  void dispose() {
    _controller.close();
  }
}
