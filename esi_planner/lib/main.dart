import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'auth_provider.dart';
import 'navigation_menu_bar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true, // Habilita Material 3
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900] // Personaliza el color del AppBar si es necesario
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, // Permite establecer un fondo
          fillColor: Colors.white, // Color de fondo blanco
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Esquinas redondeada
          ),
        )
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return authProvider.isAuthenticated
                    ? const NavigationMenuBar()
                    : const LoginScreen();
              },
            ),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const NavigationMenuBar(),
      },
    );
  }
}
