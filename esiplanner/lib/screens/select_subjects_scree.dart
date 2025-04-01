import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SelectSubjectsScreen extends StatefulWidget {
  const SelectSubjectsScreen({super.key});

  @override
  State<SelectSubjectsScreen> createState() => _SelectSubjectsScreenState();
}

class _SelectSubjectsScreenState extends State<SelectSubjectsScreen> {
  late ProfileService profileService;
  late SubjectService subjectService;
  late AuthService authService;

  bool isLoading = true;
  bool loadingDegrees = true;
  List<Map<String, dynamic>> subjects = [];
  List<String> availableDegrees = [];
  String? selectedDegree;
  String errorMessage = '';
  Set<String> selectedSubjects = {};

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    subjectService = SubjectService();
    authService = AuthService();
    _loadDegrees();
  }

  Future<void> _loadDegrees() async {
    try {
      final degrees = await subjectService.getAllDegrees();
      if (mounted) {
        setState(() {
          availableDegrees = degrees;
          loadingDegrees = false;
        });
      }
      // Cargar el grado del usuario por defecto si está disponible
      _loadUserDegree();
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar los grados disponibles: $e';
          loadingDegrees = false;
        });
      }
    }
  }

  Future<void> _loadUserDegree() async {
    final String? username = Provider.of<AuthProvider>(context, listen: false).username;
    if (username == null) return;

    try {
      final profileData = await profileService.getProfileData(username: username);
      final degree = profileData["degree"];

      if (degree != null && availableDegrees.contains(degree)) {
        if (mounted) {
          setState(() {
            selectedDegree = degree;
          });
        }
        _loadSubjects();
      }
    } catch (e) {
      // No es crítico si falla, simplemente no cargamos el grado del usuario
      print('Error al cargar el grado del usuario: $e');
    }
  }

  Future<void> _loadSubjects() async {
    if (selectedDegree == null) return;

    setState(() {
      isLoading = true;
      subjects = [];
      selectedSubjects = {};
    });

    try {
      final degreeData = await subjectService.getDegreeData(degreeName: selectedDegree!);

      if (degreeData['subjects'] != null) {
        List<Map<String, dynamic>> updatedSubjects = [];

        for (var subject in degreeData['subjects']) {
          final subjectData = await subjectService.getSubjectData(codeSubject: subject['code']);
          updatedSubjects.add({
            'name': subjectData['name'] ?? subject['name'],
            'code': subject['code'],
          });
        }

        if (mounted) {
          setState(() {
            subjects = updatedSubjects;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'No se encontraron asignaturas para este grado';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar las asignaturas: $e';
          isLoading = false;
        });
      }
    }
  }

  void _navigateToGroupsScreen() {
    if (selectedSubjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una asignatura'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectGroupsScreen(
          selectedSubjectCodes: selectedSubjects.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tus asignaturas', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _navigateToGroupsScreen,
          )
        ],
      ),
      body: loadingDegrees
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  // Selector de grado
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: DropdownButtonFormField<String>(
                        value: selectedDegree,
                        decoration: InputDecoration(
                          labelText: 'Selecciona un grado',
                          border: InputBorder.none,
                          icon: Icon(Icons.school, color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo),
                        ),
                        items: availableDegrees.map((degree) {
                          return DropdownMenuItem<String>(
                            value: degree,
                            child: Text(degree),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDegree = newValue;
                          });
                          _loadSubjects();
                        },
                        isExpanded: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (errorMessage.isNotEmpty) ...[
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (selectedDegree != null) ...[
                    Expanded(
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : subjects.isEmpty
                              ? Center(
                                  child: Text(
                                    'No hay asignaturas disponibles para este grado',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: subjects.length,
                                  itemBuilder: (context, index) {
                                    final subject = subjects[index];
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      elevation: 4,
                                      margin: const EdgeInsets.symmetric(vertical: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isDarkMode
                                                ? [Colors.grey.shade900, Colors.grey.shade900]
                                                : [Colors.indigo.shade50, Colors.white],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.book,
                                                    size: 24,
                                                    color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      subject['name'] ?? 'No Name',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: isDarkMode ? Colors.white : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.code,
                                                    size: 20,
                                                    color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      subject['code'],
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: isDarkMode ? Colors.white : Colors.black,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              SwitchListTile(
                                                title: Text(
                                                  'Seleccionar asignatura',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: isDarkMode ? Colors.white : Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                value: selectedSubjects.contains(subject['code']),
                                                onChanged: (bool selected) {
                                                  setState(() {
                                                    if (selected) {
                                                      selectedSubjects.add(subject['code']);
                                                    } else {
                                                      selectedSubjects.remove(subject['code']);
                                                    }
                                                  });
                                                },
                                                activeColor: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
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
                    Expanded(
                      child: Center(
                        child: Text(
                          'Selecciona un grado para ver sus asignaturas',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}