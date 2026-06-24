import 'package:flutter_test/flutter_test.dart';

import 'package:secure_banking_app/main.dart';

void main() {
  testWidgets('App launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SecureBankingApp());
    await tester.pump();

    expect(find.text('Secure Banking App'), findsOneWidget);
  });
}
