// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:baby_cry_interpreter_ai/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Initialize dotenv for testing
    dotenv.testLoad(fileInput: '''
AI_BASE_URL=https://api.example.com
AI_API_KEY=test_key
AI_MODEL=gemini-pro
''');

    // Build our app and trigger a frame.
    await tester.pumpWidget(const InfantCryDiagnosticApp());
    await tester.pumpAndSettle();

    // Verify that the app title is present.
    expect(find.text('Infant Cry Diagnostic System'), findsOneWidget);
    expect(find.text('Ready for Diagnostic Input'), findsOneWidget);
  });
}
