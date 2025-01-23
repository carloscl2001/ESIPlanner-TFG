import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GridView.count(
          crossAxisCount: 2, // 2 columnas
          crossAxisSpacing: 10, // Espacio entre columnas
          mainAxisSpacing: 10, // Espacio entre filas
          padding: const EdgeInsets.all(16), // Espaciado exterior
          shrinkWrap: true, // Ajustar al contenido
          children: [
            _buildCard(context, 'Ver tu perfil', '/viewProfile'),
            _buildCard(context, 'Modificar tu perfil', '/editPassWordProfile'),
            _buildCard(context, 'Tus asignaturas', '/viewSubjectsProfile'),
            _buildCard(context, 'Modificar tus asignaturas', '/editSubjectsProfile'),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String text, String route) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route);
        },
        child: Container(
          alignment: Alignment.center, // Centra el contenido horizontal y verticalmente
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
