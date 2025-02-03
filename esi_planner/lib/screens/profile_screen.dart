import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart'; // Importa el ThemeProvider
import '../widgets/custom_cards.dart'; // Importa el CustomCard

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtén el ThemeProvider
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.indigo, // Color de la barra de navegación
      ),
      body: Column(
        children: [
          // Interruptor para cambiar entre modo claro y oscuro
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
                          colors: [Colors.grey.shade900, Colors.grey.shade900], // Gradiente claro
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )// Sin gradiente en modo oscuro
                      : LinearGradient(
                          colors: [Colors.indigo.shade50, Colors.white], // Gradiente claro
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(12), // Bordes redondeados
                ),
                child: SwitchListTile(
                  title: Text(
                    isDarkMode ? 'Modo Oscuro' : 'Modo Claro', // Cambia el texto según el tema
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: themeProvider.themeMode == ThemeMode.dark,
                  onChanged: (value) {
                    themeProvider.toggleTheme(value); // Cambia el tema
                  },
                  activeColor: Colors.white, // Color del interruptor cuando está activado
                  secondary: Icon(
                    isDarkMode
                        ? Icons.nightlight_round // Luna cuando está activado
                        : Icons.wb_sunny, // Sol cuando no está activado
                    color: isDarkMode
                        ? Colors.white
                        : Colors.yellow, // Cambia el color según el modo
                  ),
                ),
              ),

            ),
          ),
          // GridView con las tarjetas reutilizando CustomCard
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 2 columnas
              crossAxisSpacing: 16, // Espacio entre columnas
              mainAxisSpacing: 16, // Espacio entre filas
              padding: const EdgeInsets.all(16), // Espaciado exterior
              shrinkWrap: true, // Ajustar al contenido
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
        ],
      ),
    );
  }
}
