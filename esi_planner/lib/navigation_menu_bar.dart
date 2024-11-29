import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/messages_screen.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: logout, // Llamada al método de logout
            color: Colors.white,
          ),
        ],
        backgroundColor: Colors.grey[850],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.white,
        backgroundColor: Colors.grey[900],
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home_outlined),
            icon: Icon(Icons.home_outlined, color: Colors.white),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, color: Colors.white),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_view_week_rounded, color: Colors.white),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        const HomeScreen(),
        const NotificationsScreen(),
        const MessagesScreen(),
        const ProfileScreen(),
      ][currentPageIndex],
    );
  }
}
