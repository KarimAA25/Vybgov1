import 'package:admin/app/modules/splash_screen/controllers/splash_screen_controller.dart';
import 'package:admin/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _StubPage extends StatelessWidget {
  final String label;
  const _StubPage(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, textDirection: TextDirection.ltr);
  }
}

void main() {
  testWidgets('Initial routing: logged out -> login', (WidgetTester tester) async {
    final route = SplashScreenController.routeForLoginState(isLoggedIn: false);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: route,
        getPages: [
          GetPage(name: Routes.LOGIN_PAGE, page: () => const _StubPage('login')),
          GetPage(name: Routes.DASHBOARD_SCREEN, page: () => const _StubPage('dashboard')),
        ],
      ),
    );

    await tester.pump();
    expect(find.text('login'), findsOneWidget);
  });

  testWidgets('Initial routing: logged in -> dashboard', (WidgetTester tester) async {
    final route = SplashScreenController.routeForLoginState(isLoggedIn: true);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: route,
        getPages: [
          GetPage(name: Routes.LOGIN_PAGE, page: () => const _StubPage('login')),
          GetPage(name: Routes.DASHBOARD_SCREEN, page: () => const _StubPage('dashboard')),
        ],
      ),
    );

    await tester.pump();
    expect(find.text('dashboard'), findsOneWidget);
  });
}
