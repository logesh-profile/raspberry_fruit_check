import 'package:flutter_test/flutter_test.dart';
import 'package:ripenx_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RipenxApp());
    expect(find.byType(RipenxApp), findsOneWidget);
  });
}
