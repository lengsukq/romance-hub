// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:romance_hub_flutter/core/auth/auth_notifier.dart';
import 'package:romance_hub_flutter/core/routes/app_router.dart';
import 'package:romance_hub_flutter/main.dart';

void main() {
  testWidgets('renders login page smoke test', (WidgetTester tester) async {
    final authNotifier = AuthNotifier()..setLoggedIn(false);
    final router = createAppRouter(authNotifier);

    await tester.pumpWidget(MyApp(router: router, authNotifier: authNotifier));
    await tester.pump();

    expect(find.text('锦书'), findsWidgets);
    expect(find.text('登入'), findsOneWidget);
  });
}
