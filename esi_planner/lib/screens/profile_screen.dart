import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo, // Color de la barra de navegación
      ),
      body: Center(
        child: GridView.count(
          crossAxisCount: 2, // 2 columnas
          crossAxisSpacing: 16, // Espacio entre columnas
          mainAxisSpacing: 16, // Espacio entre filas
          padding: const EdgeInsets.all(16), // Espaciado exterior
          shrinkWrap: true, // Ajustar al contenido
          children: [
            _buildCard(context, 'Ver tu perfil', Icons.person, '/viewProfile'),
            _buildCard(context, 'Cambiar la contraseña', Icons.lock, '/editPassWordProfile'),
            _buildCard(context, 'Tus asignaturas', Icons.school, '/viewSubjectsProfile'),
            _buildCard(context, 'Modificar tus asignaturas', Icons.edit, '/editSubjectsProfile'),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String text, IconData icon, String route) {
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
              colors: [Colors.indigo.shade50, Colors.white], // Degradado suave
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
                  color: Colors.indigo.shade700, // Color del icono
                ),
                const SizedBox(height: 12), // Espaciado entre el icono y el texto
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.indigo.shade900, // Color del texto
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