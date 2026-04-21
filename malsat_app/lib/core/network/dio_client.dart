import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Compile-time override — pass via --dart-define=API_BASE_URL=https://...
// This takes precedence over the runtime .env file, which is the correct
// behavior for release/TestFlight builds where the bundled .env may be
// missing or pointing at a dev URL.
const _compileTimeBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '',
);

// Production fallback — used when neither --dart-define nor .env is set.
const _productionBaseUrl = 'https://malsat.altailabs.club';

Dio createDio() {
  final baseUrl = _compileTimeBaseUrl.isNotEmpty
      ? _compileTimeBaseUrl
      : (dotenv.env['API_BASE_URL'] ?? _productionBaseUrl);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  assert(() {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('[DIO] $obj'),
    ));
    return true;
  }());

  return dio;
}
