import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../services/auth_service.dart';
import '../auth_provider.dart';

class EditSubjectsProfileScreen extends StatefulWidget {
  const EditSubjectsProfileScreen({super.key});

  @override
  State<EditSubjectsProfileScreen> createState() => _EditSubjectsProfileScreenState();
}

class _EditSubjectsProfileScreenState extends State<EditSubjectsProfileScreen> {
  late ProfileService profileService;
  late SubjectService subjectService;
  late AuthService authService;

  bool isLoading = true;
  List<Map<String, dynamic>> subjects = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    subjectService = SubjectService();
    authService = AuthService();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
  final String? username = Provider.of<AuthProvider>(context, listen: false).username;

  if (username != null) {
    // 1. Obtener los datos del perfil del usuario
    final profileData = await profileService.getProfileData(username: username);
    final degree = profileData["degree"]?.toString().trim();  // Convertir y limpiar el grado

    print("Degree desde el perfil: $degree"); // Imprimir degree

   if (degree != null) {
      // 2. Llamar a getDegrees para obtener todos los grados disponibles
      final degrees = await authService.getDegrees();

      print("Grados disponibles: $degrees"); // Imprimir los grados disponibles

      // 3. Filtrar el grado que coincida con el grado del usuario
      final matchingDegree = degrees.firstWhere(
        (d) {
          final degreeName = d["name"]?.toString().trim().toLowerCase() ?? '';
          final userDegree = degree.trim().toLowerCase();
          print("Comparando: $degreeName == $userDegree");  // Ver los valores comparados
          return degreeName == userDegree;
        },
        orElse: () => {} // Retorna un mapa vacío en caso de no encontrar el grado
      );

      if (matchingDegree.isNotEmpty) {
        print("Grado encontrado: $matchingDegree");  // Imprimir el grado encontrado
        // Continuar con el siguiente paso
      } else {
        setState(() {
          errorMessage = 'Grado no encontrado en la lista de grados';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'No se encontró el grado en los datos del perfil';
        isLoading = false;
      });
    }
  } else {
    setState(() {
      errorMessage = 'Usuario no autenticado';
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tus asignaturas y grupos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                  if (subjects.isNotEmpty) ...[
                    Expanded(
                      child: ListView.builder(
                        itemCount: subjects.length,
                        itemBuilder: (context, index) {
                          final subject = subjects[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    subject['name'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.code, color: Colors.indigo),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${subject['code']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Selecciona tu grupo:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Mostrar los grupos con un Checkbox
                                  ...subject['groups'].map<Widget>((group) {
                                    return CheckboxListTile(
                                      title: Text(group),
                                      value: false, // Aquí deberías manejar el estado de selección
                                      onChanged: (bool? value) {
                                        // Actualiza el estado de selección
                                      },
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    const Text('No hay asignaturas disponibles'),
                  ]
                ],
              ),
            ),
    );
  }
}
