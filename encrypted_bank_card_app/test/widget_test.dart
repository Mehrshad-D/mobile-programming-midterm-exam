import 'package:flutter_test/flutter_test.dart';

import 'package:encrypted_bank_card_app/main.dart';

void main() {
  testWidgets('App launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EncryptedBankCardApp());
    expect(find.text('Encrypted Bank Card'), findsOneWidget);
    expect(find.text('Educational purposes only'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  });
}
