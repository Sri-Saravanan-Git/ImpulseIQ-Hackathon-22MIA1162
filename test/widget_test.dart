import 'package:flutter_test/flutter_test.dart';
import 'package:behavioural_22mia1162_hackathon/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const ImpulseApp());
  });
}
