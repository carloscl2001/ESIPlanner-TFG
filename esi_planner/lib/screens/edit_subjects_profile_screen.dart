// view_subjects_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../auth_provider.dart';

class EditSubjectsProfileScreen extends StatefulWidget {
  const EditSubjectsProfileScreen({super.key});

  @override
   State<EditSubjectsProfileScreen> createState() => _EditSubjectsProfileScreenState();
}

class _EditSubjectsProfileScreenState extends State<EditSubjectsProfileScreen> {
  late ProfileService profileService;

  bool isLoading = true;
  Map<String, dynamic> userProfile = {};  // Cambiar profileData a userProfile
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    _loadUserProfile();
  }

  
  Future<void> _loadUserProfile() async {
    final String? username = Provider.of<AuthProvider>(context, listen: false).username;

    if (username != null) {
      print('Haciendo llamada a la API con el username: $username');
      final profileData = await profileService.getProfileData(username: username);
      print('Resultado de la API: $profileData');

      setState(() {
        if (profileData.isEmpty) {
          errorMessage = 'No se pudo obtener la información del perfil';
        } else {
          userProfile = profileData ?? {};  // Asegúrate de obtener los datos correctamente
          print('DATOS DE USERPROFILE: $userProfile');
        }
        isLoading = false;  // Detén el círculo de carga
      });
    } else {
      setState(() {
        errorMessage = "El nombre de usuario no está disponible";
        isLoading = false;  // Detén el círculo de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu perfil',  style: TextStyle(color: Colors.white), ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  // Muestra el círculo de carga mientras se espera
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  if (errorMessage.isNotEmpty) ...[
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Muestra los datos del usuario
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Nombre: ${userProfile['name'] ?? 'Cargando...'}'),
                          const SizedBox(height: 10),
                          Text('Apellido: ${userProfile['surname'] ?? 'Cargando...'}'),
                          const SizedBox(height: 10),
                          Text('Email: ${userProfile['email'] ?? 'Cargando...'}'),
                          const SizedBox(height: 10),
                          Text('Grado: ${userProfile['degree'] ?? 'Cargando...'}'),
                          const SizedBox(height: 10),
                          Text('Username: ${userProfile['username'] ?? 'Cargando...'}'),
                          const SizedBox(height: 10),
                          if (userProfile['subjects'] != null && userProfile['subjects'].isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Text('Asignaturas:'),
                            ...userProfile['subjects'].map<Widget>((subject) {
                              return Text('- ${subject['code'] ?? 'Sin código'}');
                            }).toList(),
                          ],
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}