import 'package:driver/app/modules/login/views/login_view.dart';
import 'package:driver/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Driver login view smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => DarkThemeProvider(),
          child: const LoginView(),
        ),
      ),
    );

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.byType(TextFormField), findsWidgets);
  });
}
