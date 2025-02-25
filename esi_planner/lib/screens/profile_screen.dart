import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_cards.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void logout(BuildContext context) {
    context.read<AuthProvider>().logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.indigo,
      ),
      body: Column(
        children: [
          // Interruptor de modo oscuro
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? LinearGradient(
                          colors: [Colors.grey.shade900, Colors.grey.shade900],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.indigo.shade50, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: Text(
                    isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value);
                  },
                  activeColor: Colors.yellow.shade700,
                  inactiveThumbColor: Colors.indigo.shade700,
                  secondary: Icon(
                    isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                    color: isDarkMode ? Colors.white : Colors.yellow,
                  ),
                ),
              ),
            ),
          ),

          // GridView con las tarjetas reutilizando CustomCard
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: const [
                CustomCard(
                  text: 'Mi perfil',
                  icon: Icons.person,
                  route: '/viewProfile',
                ),
                CustomCard(
                  text: 'Cambiar la contraseña',
                  icon: Icons.lock,
                  route: '/editPassWordProfile',
                ),
                CustomCard(
                  text: 'Mis asignaturas',
                  icon: Icons.school,
                  route: '/viewSubjectsProfile',
                ),
                CustomCard(
                  text: 'Cambiar mis asignaturas',
                  icon: Icons.edit,
                  route: '/editSubjectsProfile',
                ),
              ],
            ),
          ),

          // Cerrar sesión alineado al final
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? LinearGradient(
                          colors: [Colors.grey.shade900, Colors.grey.shade900],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.indigo.shade50, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  onTap: () => logout(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
