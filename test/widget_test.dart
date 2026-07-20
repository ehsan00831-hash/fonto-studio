// Present so `flutter create` does not generate its default counter-app test
// (which references a non-existent MyApp and would break the build).
//
// The substantive tests live in models_test.dart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke: a MaterialApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: Text('Fonto')))),
    );
    expect(find.text('Fonto'), findsOneWidget);
  });
}
