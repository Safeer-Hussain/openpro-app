import 'package:dio/dio.dart';

import 'mock_network_interceptor.dart';

class ApiClient {
  late final Dio dio;
  final MockNetworkInterceptor mockInterceptor;

  ApiClient({required this.mockInterceptor}) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openpro.internal/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Platform': 'Flutter',
          'X-Client-Architecture': 'Clean-MVVM',
        },
      ),
    );
    dio.interceptors.add(mockInterceptor);
  }
}
