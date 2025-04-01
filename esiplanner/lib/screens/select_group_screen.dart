
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subject_service.dart';
import 'package:esiplanner/services/profile_service.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SelectGroupsScreen extends StatefulWidget {
  final List<String> selectedSubjectCodes;

  const SelectGroupsScreen({super.key, required this.selectedSubjectCodes});

  @override
  State<SelectGroupsScreen> createState() => _SelectGroupsScreenState();
}

class _SelectGroupsScreenState extends State<SelectGroupsScreen> {
  late SubjectService subjectService;
  late ProfileService profileService;
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> subjects = [];
  Map<String, Set<String>> selectedGroupTypes = {};

  @override
  void initState() {
    super.initState();
    subjectService = SubjectService();
    profileService = ProfileService();
    _loadSubjectsData();
  }

  Future<void> _loadSubjectsData() async {
    try {
      List<Map<String, dynamic>> loadedSubjects = [];

      for (var code in widget.selectedSubjectCodes) {
        final subjectData = await subjectService.getSubjectData(codeSubject: code);
        loadedSubjects.add({
          'name': subjectData['name'],
          'code': code,
          'classes': subjectData['classes'] ?? [],
        });
      }

      if (mounted) {
        setState(() {
          subjects = loadedSubjects;
          isLoading = false;
          // Inicializar todas las asignaturas como seleccionadas
          for (var subject in subjects) {
            selectedGroupTypes[subject['code']] = {};
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar los datos de las asignaturas: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSelections() async {
    final String? username = Provider.of<AuthProvider>(context, listen: false).username;
    if (username == null) return;

    try {
      List<Map<String, dynamic>> selectedSubjects = selectedGroupTypes.entries.map((entry) {
        return {
          'code': entry.key,
          'types': entry.value.toList(),
        };
      }).toList();

      await profileService.updateSubjects(username: username, subjects: selectedSubjects);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Selecciones guardadas exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String getGroupLabel(String letter) {
    switch (letter) {
      case 'A': return 'Grupo de teoría';
      case 'B': return 'Grupo de problemas';
      case 'C': return 'Grupo de prácticas informáticas';
      case 'D': return 'Prácticas de laboratorio';
      case 'X': return 'Grupo de teoría-prácticas';
      default: return 'Grupo $letter';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona tus grupos', style: TextStyle(color: Colors.white)),
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: groupedTypes.keys.map<Widget>((letter) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            getGroupLabel(letter),
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                              color: isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: groupedTypes[letter]!.map<Widget>((type) {
                                              return ChoiceChip(
                                                label: Text(
                                                  type,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDarkMode ? Colors.yellow.shade700 : Colors.indigo,
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
                                                selectedColor: isDarkMode ? Colors.black : Colors.indigo.shade100,
                                                backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  side: BorderSide(color: isDarkMode ? Colors.grey.shade200 : Colors.indigo.shade300),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      );
                                    }).toList(),
                                  ),
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