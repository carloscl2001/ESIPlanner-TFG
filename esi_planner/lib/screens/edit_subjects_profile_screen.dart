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
  Map<String, Set<String>> selectedGroupTypes = {}; // Almacenar grupos seleccionados por asignatura

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
      final profileData = await profileService.getProfileData(username: username);
      final degree = profileData["degree"];

      if (degree != null) {
        final degreeData = await subjectService.getDegreeData(degreeName: degree);

        if (degreeData['subjects'] != null) {
          List<Map<String, dynamic>> updatedSubjects = [];

          for (var subject in degreeData['subjects']) {
            final subjectData = await subjectService.getSubjectData(codeSubject: subject['code']);
            updatedSubjects.add({
              'name': subjectData['name'] ?? subject['name'],
              'code': subject['code'],
              'classes': subjectData['classes'] ?? [],
            });
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

  Future<void> _saveSelections() async {
    final String? username = Provider.of<AuthProvider>(context, listen: false).username;
    if (username == null) return;

    List<Map<String, dynamic>> selectedSubjects = selectedGroupTypes.entries.map((entry) {
      return {
        'code': entry.key,
        'types': entry.value.toList(),
      };
    }).toList();

    await subjectService.updateSubjects(username: username, subjects: selectedSubjects);
  }

  String getGroupLabel(String letter) {
    switch (letter) {
      case 'A':
        return 'Grupo de teoría';
      case 'B':
        return 'Grupo de problemas';
      case 'C':
        return 'Grupo de prácticas informáticas';
      case 'D':
        return 'Prácticas de laboratorio';
      case 'X':
        return 'Grupo de teoría-prácticas';
      default:
        return 'Grupo $letter';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tus asignaturas y grupos', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSelections,
          )
        ],
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        Map<String, List<String>> groupedTypes = {};

                        for (var group in subject['classes']) {
                          final type = group['type'];
                          final letter = type[0];
                          if (!groupedTypes.containsKey(letter)) {
                            groupedTypes[letter] = [];
                          }
                          groupedTypes[letter]?.add(type);
                        }

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
                                  // Nombre de la asignatura con icono
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
                                          subject['name'] ?? 'No Name',
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
                                  // Código de la asignatura con icono
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
                                          subject['code'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.indigo.shade700,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Switch para seleccionar la asignatura
                                  SwitchListTile(
                                    title: const Text(
                                      'Seleccionar asignatura',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    value: selectedGroupTypes.containsKey(subject['code']),
                                    onChanged: (bool selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedGroupTypes[subject['code']] = {};
                                        } else {
                                          selectedGroupTypes.remove(subject['code']);
                                        }
                                      });
                                    },
                                    activeColor: Colors.indigo, // Color del Switch cuando está activado
                                    inactiveThumbColor: Colors.grey, // Color del "thumb" cuando está desactivado
                                    inactiveTrackColor: Colors.grey.withOpacity(0.5), // Color de la pista cuando está desactivado
                                  ),
                                  // Grupos seleccionables
                                  if (selectedGroupTypes.containsKey(subject['code'])) ...[
                                    const SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: groupedTypes.keys.map<Widget>((letter) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            // Etiqueta del grupo
                                            Text(
                                              getGroupLabel(letter),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.indigo.shade900,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Chips para seleccionar los grupos
                                            Wrap(
                                              spacing: 8, // Espaciado horizontal entre chips
                                              runSpacing: 8, // Espaciado vertical entre chips
                                              children: groupedTypes[letter]!.map<Widget>((type) {
                                                return ChoiceChip(
                                                  label: Text(
                                                    type,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.indigo,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  selected: selectedGroupTypes[subject['code']]?.contains(type) ?? false,
                                                  onSelected: (bool selected) {
                                                    setState(() {
                                                      if (selected) {
                                                        selectedGroupTypes[subject['code']]!.removeWhere((t) => t.startsWith(letter));
                                                        selectedGroupTypes[subject['code']]!.add(type);
                                                      }
                                                    });
                                                  },
                                                  selectedColor: Colors.indigo.shade100, // Color de fondo cuando está seleccionado
                                                  backgroundColor: Colors.white, // Color de fondo cuando no está seleccionado
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12), // Bordes redondeados
                                                    side: BorderSide(color: Colors.indigo.shade300), // Borde con color
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(height: 10),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}