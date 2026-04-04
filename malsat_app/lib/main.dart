import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // .env is optional — release/TestFlight builds use --dart-define instead.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // No .env bundled — fall back to --dart-define / production defaults.
  }
  runApp(
    const ProviderScope(
      child: MalsatApp(),
    ),
  );
}
