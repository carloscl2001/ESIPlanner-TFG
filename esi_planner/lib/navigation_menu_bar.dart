import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/timetable_screen.dart';
import 'screens/agenda_screen.dart';
import 'screens/profile_screen.dart';

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


    return Scaffold(
      appBar: AppBar(
        title: Text(
          username,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: logout, // Llamada al método de logout
            color: Colors.white,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.white,
        backgroundColor: Colors.grey[850],
        selectedIndex: currentPageIndex,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home_outlined),
            icon: Icon(Icons.home_outlined, color: Colors.white),
            label: 'Home', 
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_month_outlined),
            icon: Icon(Icons.calendar_month_outlined, color: Colors.white),
            label: 'Horario',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.calendar_view_week_rounded),
            icon: Icon(Icons.calendar_view_week_rounded, color: Colors.white),
            label: 'Agenda',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Perfil',
          ),
        ],
      ),
      body: <Widget>[
        const HomeScreen(),
        const TimetableScreen(),
        const AgendaScreen(),
        const ProfileScreen(),
      ][currentPageIndex],
    );
  }
}
