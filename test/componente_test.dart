import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renderiza el titulo principal', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('Recorridos Patrimoniales'))),
      ),
    );

    expect(find.text('Recorridos Patrimoniales'), findsOneWidget);
  });
}
