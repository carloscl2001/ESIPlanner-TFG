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
          backgroundColor: Colors.grey[850] // Personaliza el color del AppBar si es necesario
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, // Permite establecer un fondo
          fillColor: Colors.white, // Color de fondo blanco
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Esquinas redondeadas
          ),
          labelStyle: const TextStyle(color:  Color.fromRGBO(0, 89, 255, 1.0)), // Labels en blanco
          hintStyle: TextStyle(color: Colors.grey[400]), // Estilo del texto de ayuda
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color:  Color.fromRGBO(0, 89, 255, 1.0), width: 1.5), // Borde en azul al estar habilitado
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color:  Color.fromRGBO(0, 89, 255, 1.0), width: 3), // Borde más grueso al estar enfocado
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white), // Labels del NavigationBar en blanco
          ),
        ),
        cardTheme: CardTheme(
          color: const Color.fromRGBO(227, 233, 255, 1), // Color del Card
          elevation: 8, // Sombra para darle relieve
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Esquinas redondeadas
            side: BorderSide(color: Colors.white, width: 2), // Borde blanco
          ),
        ),
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
