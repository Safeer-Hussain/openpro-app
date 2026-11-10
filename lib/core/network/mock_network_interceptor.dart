import 'dart:math';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class MockNetworkInterceptor extends Interceptor {
  int simulatedLatencyMs = 650;
  bool simulateError503 = false;

  MockNetworkInterceptor() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      simulatedLatencyMs =
          prefs.getInt(AppConstants.prefSimulatedLatencyMs) ?? 650;
      simulateError503 =
          prefs.getBool(AppConstants.prefSimulateError503) ?? false;
    } catch (_) {}
  }

  Future<void> updateSettings({
    required int latencyMs,
    required bool error503,
  }) async {
    simulatedLatencyMs = latencyMs;
    simulateError503 = error503;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.prefSimulatedLatencyMs, latencyMs);
      await prefs.setBool(AppConstants.prefSimulateError503, error503);
    } catch (_) {}
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Inject configured simulated latency
    final jitter = Random().nextInt(150);
    final totalDelay = simulatedLatencyMs + jitter;
    await Future.delayed(Duration(milliseconds: totalDelay));

    if (simulateError503) {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 503,
            statusMessage: 'Simulated 503 Service Unavailable (Debug Mode)',
            data: {
              'error': 'Service temporarily overloaded. Retry available in debug drawer.',
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );
    }

    return handler.next(options);
  }
}
