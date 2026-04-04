import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:malsat_app/app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MalsatApp()),
    );
    // App should render without crashing
    expect(find.text('MalSat'), findsOneWidget);
  });
}
