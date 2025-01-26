import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../services/auth_service.dart';
import '../auth_provider.dart';

class EditSubjectsProfileScreen extends StatefulWidget {
  const EditSubjectsProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditSubjectsProfileScreen> createState() =>
      _EditSubjectsProfileScreenState();
}

class _EditSubjectsProfileScreenState extends State<EditSubjectsProfileScreen> {
  late ProfileService profileService;
  late SubjectService subjectService;
  late AuthService authService;

  bool isLoading = true;
  List<Map<String, dynamic>> subjects = [];
  String errorMessage = '';
  Map<String, String?> selectedGroupTypes = {}; // Mapa para almacenar la selección de grupos por asignatura
  Set<String> selectedTypes = {}; // Set para controlar los tipos seleccionados (único por letra)

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    subjectService = SubjectService();
    authService = AuthService();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final String? username =
        Provider.of<AuthProvider>(context, listen: false).username;

    if (username != null) {
      // 1. Obtener los datos del perfil del usuario
      final profileData = await profileService.getProfileData(username: username);
      final degree = profileData["degree"]; // Convertir y limpiar el grado

      print("Degree desde el perfil: $degree"); // Imprimir degree

      if (degree != null) {
        // 2. Llamar a getDegreeData para obtener todos los grados disponibles
        final degreeData = await subjectService.getDegreeData(degreeName: degree);

        print("Asignaturas obtenidas: ${degreeData['subjects']}"); // Imprimir las asignaturas obtenidas

        // Verificar si se obtuvieron las asignaturas
        if (degreeData['subjects'] != null) {
          List<Map<String, dynamic>> updatedSubjects = [];

          // 3. Llamar a getSubjectData para obtener detalles adicionales por cada código de asignatura
          for (var subject in degreeData['subjects']) {
            final subjectData = await subjectService.getSubjectData(codeSubject: subject['code']);
            if (subjectData != null) {
              print(subject['name']);
              updatedSubjects.add({
                'name': subjectData['name'] ?? subject['name'], // Si no hay nombre, usar el de la asignatura
                'code': subject['code'],
                'classes': subjectData['classes'] ?? [],  // Aquí guardamos las clases con su "type"
              });
            }
          }

          setState(() {
            subjects = updatedSubjects;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'No se encontraron asignaturas para este grado';
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

  // Método para verificar si el tipo ya está seleccionado en la misma letra
  bool isTypeAlreadySelected(String type) {
    final letter = type[0]; // Obtenemos la primera letra del tipo (A, B, etc.)
    return selectedTypes.contains(letter);
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
                          // Agrupar los tipos por letra
                          Map<String, List<String>> groupedTypes = {};

                          for (var group in subject['classes']) {
                            final type = group['type'];
                            final letter = type[0]; // Obtener la letra (A, B, etc.)
                            if (!groupedTypes.containsKey(letter)) {
                              groupedTypes[letter] = [];
                            }
                            groupedTypes[letter]?.add(type);
                          }

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
                                    subject['name'] ?? 'No Name',
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
                                  // Mostrar los grupos con las columnas para cada tipo
                                  Row(
                                    children: groupedTypes.keys.map<Widget>((letter) {
                                      return Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              letter, // Título de la columna (A, B, C...)
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            ...groupedTypes[letter]!.map<Widget>((type) {
                                              return RadioListTile<String>(
                                                title: Text(type),
                                                value: type,
                                                groupValue: selectedGroupTypes[subject['code']],
                                                onChanged: (String? value) {
                                                  if (value != null && !isTypeAlreadySelected(value)) {
                                                    setState(() {
                                                      selectedGroupTypes[subject['code']] = value;
                                                      selectedTypes.add(value[0]); // Agregar la letra del tipo
                                                    });
                                                  } else {
                                                    // Mostrar un mensaje si ya se seleccionó un tipo de esa letra
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Ya has seleccionado un grupo de tipo $letter'),
                                                      ),
                                                    );
                                                  }
                                                },
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 10),
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
