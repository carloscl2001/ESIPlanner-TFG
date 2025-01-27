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
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Tus grupos:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
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
                                                const Icon(
                                                  Icons.group,
                                                  color: Colors.indigo,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  type,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.indigo,
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
