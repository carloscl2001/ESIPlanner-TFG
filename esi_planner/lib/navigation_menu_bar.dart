import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/timetable_screen.dart';
import 'screens/agenda_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/theme_provider.dart'; // Importa el ThemeProvider

class NavigationMenuBar extends StatefulWidget {
  const NavigationMenuBar({super.key});

  @override
  State<NavigationMenuBar> createState() => _NavigationMenuBarState();
}

class _NavigationMenuBarState extends State<NavigationMenuBar> {
  int currentPageIndex = 0;

  // Método para hacer logout
  void logout() {
    // Actualiza el estado de autenticación en el AuthProvider
    context.read<AuthProvider>().logout();

    // Redirige al LoginScreen
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AuthProvider>(context).username ?? 'Usuario';
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtén el ThemeProvider
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hola, $username',
          style: const TextStyle(
            color:  Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 10, // Aumenta la sombra
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color:  isDarkMode ? Colors.black : Colors.indigo.shade900, // Usas un color sólido en lugar de un gradiente
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: logout, // Llamada al método de logout
            color:  Colors.white,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow, // Mostrar siempre las etiquetas
          destinations: <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home, color: isDarkMode ? Colors.black : Colors.indigo),
              icon: const Icon(Icons.home_outlined, color: Colors.grey),
              label: 'Inicio',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.calendar_today, color: isDarkMode ? Colors.black : Colors.indigo),
              icon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
              label: 'Horario',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.calendar_view_week, color: isDarkMode ? Colors.black : Colors.indigo),
              icon: const Icon(Icons.calendar_view_week_outlined, color: Colors.grey),
              label: 'Agenda',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person, color: isDarkMode ? Colors.black : Colors.indigo),
              icon: const Icon(Icons.person_outline, color: Colors.grey),
              label: 'Perfil',
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300), // Duración de la animación
        child: <Widget>[
          const HomeScreen(),
          const TimetableScreen(),
          const AgendaScreen(),
          const ProfileScreen(),
        ][currentPageIndex],
      ),
    );
  }
}