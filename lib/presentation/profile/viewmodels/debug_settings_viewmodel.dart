import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/network/mock_network_interceptor.dart';
import '../../../core/notifications/local_notification_service.dart';

class DebugSettingsViewModel extends ChangeNotifier {
  final MockNetworkInterceptor mockInterceptor;
  final LocalNotificationService notificationService;
  final AppDatabase database;

  int _latencyMs = 650;
  bool _simulate503 = false;

  DebugSettingsViewModel({
    required this.mockInterceptor,
    required this.notificationService,
    required this.database,
  }) {
    _latencyMs = mockInterceptor.simulatedLatencyMs;
    _simulate503 = mockInterceptor.simulateError503;
  }

  int get latencyMs => _latencyMs;
  bool get simulate503 => _simulate503;

  void setLatency(int val) {
    _latencyMs = val;
    mockInterceptor.updateSettings(
      latencyMs: _latencyMs,
      error503: _simulate503,
    );
    notifyListeners();
  }

  void setSimulate503(bool val) {
    _simulate503 = val;
    mockInterceptor.updateSettings(
      latencyMs: _latencyMs,
      error503: _simulate503,
    );
    notifyListeners();
  }

  void triggerRecruiterMatch({String? company, String? role, int? score}) {
    notificationService.triggerRecruiterMatch(
      company: company,
      role: role,
      matchScore: score,
    );
  }

  Future<void> resetDatabase() async {
    await database.resetDatabase();
    notifyListeners();
  }
}
