import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'select_group_screen.dart';

class SelectSubjectsScreen extends StatefulWidget {
  const SelectSubjectsScreen({super.key});

  @override
  State<SelectSubjectsScreen> createState() => _SelectSubjectsScreenState();
}

class _SelectSubjectsScreenState extends State<SelectSubjectsScreen> {
  late ProfileService profileService;
  late SubjectService subjectService;
  late AuthService authService;

  bool isLoadingDegrees = true;
  bool isLoadingSubjects = false;
  List<String> availableDegrees = [];
  Set<String> selectedDegrees = {};
  Map<String, List<Map<String, dynamic>>> degreeSubjects = {};
  String errorMessage = '';
  Set<String> selectedSubjects = {};
  String? dropdownValue; // Valor visible en el dropdown

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    subjectService = SubjectService();
    authService = AuthService();
    _loadDegrees();
    _loadUserDegree();
  }

  Future<void> _loadDegrees() async {
    try {
      final degrees = await subjectService.getAllDegrees();
      if (mounted) {
        setState(() {
          availableDegrees = degrees;
          isLoadingDegrees = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar los grados disponibles: $e';
          isLoadingDegrees = false;
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
        _addDegreeSelection(degree);
        if (mounted) {
          setState(() {
            dropdownValue = degree;
          });
        }
      }
    } catch (e) {
      print('Error al cargar el grado del usuario: $e');
    }
  }

  Future<void> _loadSubjectsForDegree(String degree) async {
    if (degreeSubjects.containsKey(degree)) return;

    setState(() {
      isLoadingSubjects = true;
    });

    try {
      final degreeData = await subjectService.getDegreeData(degreeName: degree);

      if (degreeData['subjects'] != null) {
        List<Map<String, dynamic>> subjects = [];

        for (var subject in degreeData['subjects']) {
          final subjectData = await subjectService.getSubjectData(codeSubject: subject['code']);
          subjects.add({
            'name': subjectData['name'] ?? subject['name'],
            'code': subject['code'],
            'degree': degree,
          });
        }

        if (mounted) {
          setState(() {
            degreeSubjects[degree] = subjects;
            isLoadingSubjects = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = 'No se encontraron asignaturas para $degree';
            isLoadingSubjects = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar las asignaturas de $degree: $e';
          isLoadingSubjects = false;
        });
      }
    }
  }

  void _addDegreeSelection(String degree) {
    if (!selectedDegrees.contains(degree)) {
      setState(() {
        selectedDegrees.add(degree);
      });
      _loadSubjectsForDegree(degree);
    }
  }

  void _removeDegreeSelection(String degree) {
    setState(() {
      selectedDegrees.remove(degree);
      // Opcional: Limpiar asignaturas seleccionadas de ese grado
      selectedSubjects.removeWhere((code) => 
        degreeSubjects[degree]?.any((subject) => subject['code'] == code) ?? false);
    });
  }

  void _toggleSubjectSelection(String subjectCode) {
    setState(() {
      if (selectedSubjects.contains(subjectCode)) {
        selectedSubjects.remove(subjectCode);
      } else {
        selectedSubjects.add(subjectCode);
      }
    });
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
      body: isLoadingDegrees
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Selector de grados con dropdown
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: dropdownValue,
                            decoration: InputDecoration(
                              labelText: 'Añadir grado',
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
                              if (newValue != null && !selectedDegrees.contains(newValue)) {
                                setState(() {
                                  dropdownValue = newValue;
                                });
                                _addDegreeSelection(newValue);
                              }
                            },
                            isExpanded: true,
                          ),
                          if (selectedDegrees.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: selectedDegrees.map((degree) {
                                return Chip(
                                  label: Text(degree),
                                  onDeleted: () => _removeDegreeSelection(degree),
                                  deleteIconColor: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (errorMessage.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (isLoadingSubjects)
                  const LinearProgressIndicator(),
                Expanded(
                  child: selectedDegrees.isEmpty
                      ? Center(
                          child: Text(
                            'Añade un grado para ver sus asignaturas',
                            style: TextStyle(
                              fontSize: 18,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        )
                      : ListView(
                          children: selectedDegrees.map((degree) {
                            final subjects = degreeSubjects[degree] ?? [];
                            if (subjects.isEmpty) return Container();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Text(
                                    degree,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                                    ),
                                  ),
                                ),
                                ...subjects.map((subject) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 2,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isDarkMode
                                              ? [Colors.grey.shade800, Colors.grey.shade900]
                                              : [Colors.indigo.shade50, Colors.white],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.book,
                                                  size: 20,
                                                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    subject['name'] ?? 'No Name',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDarkMode ? Colors.white : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Switch(
                                                  value: selectedSubjects.contains(subject['code']),
                                                  onChanged: (value) => _toggleSubjectSelection(subject['code']),
                                                  activeColor: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.code,
                                                  size: 16,
                                                  color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade700,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  subject['code'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
    );
  }
}