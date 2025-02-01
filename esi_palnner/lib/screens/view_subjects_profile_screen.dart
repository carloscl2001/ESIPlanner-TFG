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
      final response = await profileService.getUserSubjects(username: username);

      if (response['success'] == true) {
        List<dynamic> subjects = response['data'];

        List<dynamic> detailedSubjects = await Future.wait(subjects.map((subject) async {
          final subjectDetails = await subjectService.getSubjectData(codeSubject: subject['code']);

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
        title: const Text('Tus asignaturas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo, // Color de la barra de navegación
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0), // Bordes más redondeados
                            ),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.indigo.shade50, Colors.white], // Degradado suave
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20.0), // Coincide con el radio de la tarjeta
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // Nombre de la asignatura
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.book, // Icono para el nombre de la asignatura
                                          size: 24,
                                          color: Colors.indigo.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible( // Permite que el texto fluya a la siguiente línea
                                          child: Text(
                                            subject['name'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.indigo.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Código de la asignatura
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.code, // Icono para el código
                                          size: 20,
                                          color: Colors.indigo.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Flexible( // Permite que el texto fluya a la siguiente línea
                                          child: Text(
                                            'Código: ${subject['code']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.indigo.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Tus grupos
                                    Text(
                                      'Tus grupos:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.indigo.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Lista de tipos de grupos
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: subject['types']
                                          .map<Widget>(
                                            (type) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 6,
                                                horizontal: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.indigo.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.group, // Icono para el tipo de grupo
                                                    color: Colors.indigo.shade700,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    type,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.indigo.shade700,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    Text(
                      'No hay asignaturas disponibles',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                  ]
                ],
              ),
            ),
    );
  }
}