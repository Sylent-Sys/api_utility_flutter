import 'package:flutter_test/flutter_test.dart';
import 'package:api_utility_flutter/main.dart';
import 'package:api_utility_flutter/providers/app_settings_provider.dart';

void main() {
  testWidgets('API Utility app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ApiUtilityApp(initialSettings: AppSettingsProvider()),
    );

    // Verify that the app loads with the home screen
    expect(find.text('Configuration'), findsWidgets);
    expect(find.text('Processing'), findsWidgets);
  });
}
