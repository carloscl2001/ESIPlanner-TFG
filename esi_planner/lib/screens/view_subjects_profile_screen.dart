import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../auth_provider.dart';

class ViewSubjectsProfileScreen extends StatefulWidget {
  const ViewSubjectsProfileScreen({super.key});

  @override
  State<ViewSubjectsProfileScreen> createState() => _ViewSubjectsProfileScreenState();
}

class _ViewSubjectsProfileScreenState extends State<ViewSubjectsProfileScreen> {
  late ProfileService profileService;
  late SubjectService subjectService;

  bool isLoading = true;
  List<dynamic> userSubjects = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    subjectService = SubjectService();
    _loadUserSubjects();
  }

  Future<void> _loadUserSubjects() async {
    final String? username = Provider.of<AuthProvider>(context, listen: false).username;

    if (username != null) {
      print('Haciendo llamada a la API con el username: $username');
      final response = await profileService.getUserSubjects(username: username);
      print('Resultado de la API: $response');

      if (response['success'] == true) {
        // Procesar las asignaturas obtenidas
        List<dynamic> subjects = response['data'];

        // Para cada asignatura, obtener su información detallada
        List<dynamic> detailedSubjects = await Future.wait(subjects.map((subject) async {
          final subjectDetails = await subjectService.getSubjectData(codeSubject: subject['code']);

          // Depuración adicional para asegurar que los datos son correctos
          print('Detalles obtenidos para la asignatura con código ${subject['code']}: $subjectDetails');

          // Validar correctamente los datos obtenidos
          if (subjectDetails.isNotEmpty && subjectDetails.containsKey('name')) {
            return {
              'code': subject['code'],
              'name': subjectDetails['name'],
              'types': subject['types'],
            };
          } else {
            return {
              'code': subject['code'],
              'name': 'Información no disponible',
              'types': subject['types'],
            };
          }
        }).toList());

        setState(() {
          userSubjects = detailedSubjects;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'No se pudo obtener la información de las asignaturas';
          isLoading = false;
        });
      }
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
        title: const Text('Tus asignaturas', style: TextStyle(color: Colors.white)),
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
                  if (userSubjects.isNotEmpty) ...[
                    Expanded(
                      child: ListView.builder(
                        itemCount: userSubjects.length,
                        itemBuilder: (context, index) {
                          final subject = userSubjects[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Código: ${subject['code']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  Text('Nombre: ${subject['name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  const Text('Grupos:'),
                                  ...subject['types'].map<Widget>((type) {
                                    return Text('- $type');
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
