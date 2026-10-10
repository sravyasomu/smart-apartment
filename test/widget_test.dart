import 'package:flutter_test/flutter_test.dart';
import 'package:smart_apartment/main.dart';

void main() {
  testWidgets('Smart Apartment app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartApartmentApp());

    expect(find.text('Smart Apartment'), findsOneWidget);
  });
}