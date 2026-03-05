import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:edu_gate/main.dart';

void main() {
  testWidgets('EduGate app renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: EduGateApp()));
    await tester.pumpAndSettle();

    expect(find.text('EduGate'), findsWidgets);
    expect(find.text('Welcome to EduGate!'), findsOneWidget);
  });
}
