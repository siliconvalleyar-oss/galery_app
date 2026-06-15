import 'package:flutter_test/flutter_test.dart';

import 'package:galery_app/main.dart';

void main() {
  testWidgets('App renders with tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('LOCAL'), findsOneWidget);
    expect(find.text('NUBE'), findsOneWidget);
    expect(find.text('Galería PRO'), findsOneWidget);
  });
}
