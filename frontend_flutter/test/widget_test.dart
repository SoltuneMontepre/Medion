// Basic Flutter widget test for MES app shell.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend_flutter/main.dart';

void main() {
  testWidgets('MES app starts at home with module links', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MESApp()));
    await tester.pumpAndSettle();

    expect(find.text('Select module'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Sales'), findsOneWidget);
  });
}
