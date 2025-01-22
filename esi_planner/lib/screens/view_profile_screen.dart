import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../auth_provider.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  late ProfileService profileService;

  bool isLoading = true;
  Map<String, dynamic> userProfile = {};  
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
          userProfile = profileData ?? {};  
          print('DATOS DE USERPROFILE: $userProfile');
        }
        isLoading = false;  
      });
    } else {
      setState(() {
        errorMessage = "El nombre de usuario no está disponible";
        isLoading = false;  
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  
          : Center(  // Centra todo el contenido
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(  // Permite desplazar el contenido si es necesario
                  child: Card(
                    elevation: 5,  // Sombra para dar un efecto de profundidad
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),  // Bordes redondeados
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Text(
                            'Username: ${userProfile['username'] ?? 'Cargando...'}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Email: ${userProfile['email'] ?? 'Cargando...'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Nombre: ${userProfile['name'] ?? 'Cargando...'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Apellido: ${userProfile['surname'] ?? 'Cargando...'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Grado: ${userProfile['degree'] ?? 'Cargando...'}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
