import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:galery_app/main.dart';

void main() {
  testWidgets('App renders with tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(GaleryApp(prefs: prefs));
    await tester.pumpAndSettle();

    expect(find.text('LOCAL'), findsOneWidget);
    expect(find.text('NUBE'), findsOneWidget);
  });
}
