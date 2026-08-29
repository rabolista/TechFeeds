import 'package:flutter_test/flutter_test.dart';

import 'package:tech_and_feeds/main.dart';

void main() {
  testWidgets('App launches and shows the Feed tab', (WidgetTester tester) async {
    await tester.pumpWidget(const TechAndFeedsApp());
    await tester.pump();

    expect(find.text('Tech and Feeds'), findsWidgets);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
