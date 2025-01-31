import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart'; // Importa el ThemeProvider

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtén el ThemeProvider

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo, // Color de la barra de navegación
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
              child: SwitchListTile(
                title: const Text(
                  'Modo oscuro',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value); // Cambia el tema
                },
                activeColor: Colors.indigo, // Color del interruptor cuando está activado
              ),
            ),
          ),
          // GridView con las tarjetas
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 2 columnas
              crossAxisSpacing: 16, // Espacio entre columnas
              mainAxisSpacing: 16, // Espacio entre filas
              padding: const EdgeInsets.all(16), // Espaciado exterior
              shrinkWrap: true, // Ajustar al contenido
              children: [
                _buildCard(context, 'Ver tu perfil', Icons.person, '/viewProfile', themeProvider),
                _buildCard(context, 'Cambiar la contraseña', Icons.lock, '/editPassWordProfile', themeProvider),
                _buildCard(context, 'Tus asignaturas', Icons.school, '/viewSubjectsProfile', themeProvider),
                _buildCard(context, 'Modificar tus asignaturas', Icons.edit, '/editSubjectsProfile', themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String text, IconData icon, String route, ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Bordes más redondeados
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(20.0), // Bordes redondeados para el InkWell
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [Colors.indigo.shade800, Colors.indigo.shade900] // Degradado oscuro
                  : [Colors.indigo.shade50, Colors.white], // Degradado claro
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0), // Coincide con el radio de la tarjeta
          ),
          alignment: Alignment.center, // Centra el contenido horizontal y verticalmente
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 40,
                  color: isDarkMode ? Colors.white : Colors.indigo.shade700, // Color del icono
                ),
                const SizedBox(height: 12), // Espaciado entre el icono y el texto
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDarkMode ? Colors.white : Colors.indigo.shade900, // Color del texto
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}