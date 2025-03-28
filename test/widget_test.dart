import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myWeather/main.dart'; // Ensure this is the correct package name

void main() {
  testWidgets('Homepage renders correctly', (WidgetTester tester) async {
    // Build our app with mock theme values
    await tester.pumpWidget(
      CupertinoApp(
        home: Homepage(
          lightMode: true, // Default to light mode
          onThemeChanged: (bool value) {}, // Empty callback for testing
        ),
      ),
    );

    // Verify initial widgets appear
    expect(find.text('iWeather'), findsOneWidget); // Check app bar title
    expect(find.text('Location'), findsOneWidget); // Check location text
  });
}
