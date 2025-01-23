import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'navigation_menu_bar.dart';

// Screens
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/view_profile_screen.dart';
import 'screens/edit_password_profile_screen.dart';
import 'screens/edit_subjects_profile_screen.dart';
import 'screens/view_subjects_profile_screen.dart';

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
        useMaterial3: true, 
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          iconTheme: const IconThemeData(color: Colors.white),
          actionsIconTheme: const IconThemeData(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          labelStyle: const TextStyle(color: Color.fromRGBO(0, 89, 255, 1.0)),
          hintStyle: TextStyle(color: Colors.grey[400]),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromRGBO(0, 89, 255, 1.0), width: 1.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color.fromRGBO(0, 89, 255, 1.0), width: 3),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(color: Colors.white),
          ),
        ),
        cardTheme: CardTheme(
          color: const Color.fromRGBO(227, 233, 255, 1),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color.fromRGBO(0, 89, 255, 1.0),
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(0, 89, 255, 1.0),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
        '/profile': (context) => const ProfileScreen(),
        '/viewProfile': (context) => const ViewProfileScreen(),
        '/editPassWordProfile': (context) => const EditPasswordProfileScreen(),
        '/viewSubjectsProfile': (context) => const ViewSubjectsProfileScreen(),
        '/editSubjectsProfile': (context) => const EditSubjectsProfileScreen(),
      },
    );
  }
}
