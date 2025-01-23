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
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(227, 233, 255, 1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(0, 89, 255, 1.0), // Fondo azul del encabezado
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(11.0),
                                topRight: Radius.circular(11.0),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: const Text(
                              'Tu perfil',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                if (errorMessage.isNotEmpty) ...[
                                  Text(
                                    errorMessage,
                                    style: const TextStyle(color: Colors.red, fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                ],
                                // Campos de perfil
                                ProfileField(
                                  label: userProfile['username'] ?? 'Cargando...',
                                ),
                                ProfileField(
                                  label: userProfile['email'] ?? 'Cargando...',
                                ),
                                ProfileField(
                                  label: userProfile['name'] ?? 'Cargando...',
                                ),
                                ProfileField(
                                  label: userProfile['surname'] ?? 'Cargando...',
                                ),
                                ProfileField(
                                  label: userProfile['degree'] ?? 'Cargando...',
                                ),
                              ],
                            ),
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

class ProfileField extends StatelessWidget {
  final String label;

  const ProfileField({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        //border: Border.all(color: Colors.black, width: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
