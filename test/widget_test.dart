import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:golfsnap_flutter/main.dart';

void main() {
  testWidgets('GolfSnap app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: GolfSnapApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the app launches without errors
    expect(find.text('GolfSnap'), findsAny);
  });
}
