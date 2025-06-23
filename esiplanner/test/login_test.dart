import 'package:esiplanner/features/login/login_widgets.dart';
import 'package:esiplanner/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';



void main() {
  testWidgets('Login form validation test', (WidgetTester tester) async {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                UsernameField(
                  controller: usernameController,
                  isDarkMode: false,
                ),
                PasswordField(
                  controller: passwordController,
                  isDarkMode: false,
                ),
                LoginButton(
                  isDarkMode: false,
                  onPressed: () {
                    // Simulación: aquí llamarías a LoginLogic(context).login()
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Verifica que los campos están en el widget
    expect(find.byKey(const Key('usernameField')), findsOneWidget);
    expect(find.byKey(const Key('passwordField')), findsOneWidget);
    expect(find.byKey(const Key('loginButton')), findsOneWidget);

    // Introducir texto
    await tester.enterText(find.byKey(const Key('usernameField')), 'robe2');
    await tester.enterText(find.byKey(const Key('passwordField')), '1234');

    expect(usernameController.text, 'robe2');
    expect(passwordController.text, '1234');

    // Pulsa el botón de login
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump(); // Actualiza el árbol de widgets

    // Aquí podrías hacer más verificaciones con mock de AuthService si usas Mockito
  });
}
