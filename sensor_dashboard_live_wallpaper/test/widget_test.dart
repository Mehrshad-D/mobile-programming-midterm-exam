import 'package:flutter_test/flutter_test.dart';
import 'package:sensor_dashboard_live_wallpaper/main.dart';

void main() {
  testWidgets('App launches splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SensorDashboardApp());
    expect(find.text('Sensor Dashboard'), findsOneWidget);
  });
}
