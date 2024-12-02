import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Asegúrate de importar tu archivo con el servicio

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<List<String>> degrees;

  @override
  void initState() {
    super.initState();
    // Llamar al método getDegrees cuando se inicializa el estado
    degrees = AuthService().getDegrees();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Grados del Usuario',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Usamos FutureBuilder para mostrar la lista de grados
          FutureBuilder<List<String>>(
            future: degrees,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (snapshot.hasData) {
                final degreeList = snapshot.data!;
                if (degreeList.isEmpty) {
                  return const Center(child: Text('No hay grados disponibles.'));
                }
                return Column(
                  children: degreeList.map((degree) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.school),
                        title: Text(degree),
                      ),
                    );
                  }).toList(),
                );
              } else {
                return const Center(child: Text('No se han encontrado grados.'));
              }
            },
          ),
        ],
      ),
    );
  }
}
