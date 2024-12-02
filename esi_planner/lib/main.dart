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
          backgroundColor: Colors.grey[850], // Personaliza el color del AppBar
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true, // Permite establecer un fondo
          fillColor: Colors.white, // Color de fondo blanco
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0), // Esquinas redondeadas
          ),
          labelStyle: const TextStyle(color: Color.fromRGBO(0, 89, 255, 1.0)), // Labels en azul
          hintStyle: TextStyle(color: Colors.grey[400]), // Estilo del texto de ayuda
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromRGBO(0, 89, 255, 1.0), width: 1.5), // Borde en azul
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromRGBO(0, 89, 255, 1.0), width: 3), // Borde más grueso
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
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromRGBO(0, 89, 255, 1.0), // Color de fondo del botón
          textTheme: ButtonTextTheme.primary, // Color del texto en blanco
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(0, 89, 255, 1.0), // Color de fondo azul
            foregroundColor: Colors.white, // Color del texto blanco
            minimumSize: const Size(double.infinity, 50), // Ancho del botón
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)), // Bordes redondeados
            ),
            textStyle: const TextStyle(
              fontSize: 20, // Tamaño de la fuente más grande
              fontWeight: FontWeight.bold, // Texto en negrita
            ),
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
