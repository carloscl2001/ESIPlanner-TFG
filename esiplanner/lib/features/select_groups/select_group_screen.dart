import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/subject_service.dart';
import '../../providers/theme_provider.dart';

class SelectGroupsScreen extends StatefulWidget {
  final List<String> selectedSubjectCodes;
  final Map<String, String> subjectDegrees;

  const SelectGroupsScreen({
    super.key, 
    required this.selectedSubjectCodes,
    required this.subjectDegrees,
  });

  @override
  State<SelectGroupsScreen> createState() => _SelectGroupsScreenState();
}

class _SelectGroupsScreenState extends State<SelectGroupsScreen> {
  late SubjectService subjectService;
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> subjects = [];
  Map<String, Map<String, String>> selectedGroups = {};

  @override
  void initState() {
    super.initState();
    subjectService = SubjectService();
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
          for (var subject in subjects) {
            selectedGroups[subject['code']] = {};
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error al cargar los datos: $e';
          isLoading = false;
        });
      }
    }
  }

  bool get _allSelectionsComplete {
    for (var subject in subjects) {
      final groups = subject['classes'] as List;
      final requiredTypes = groups.map((g) => g['type'][0]).toSet();
      final selectedTypes = selectedGroups[subject['code']]?.keys.toSet() ?? {};

      if (requiredTypes.length != selectedTypes.length) {
        return false;
      }
    }
    return true;
  }

  Future<void> _saveSelections() async {
    if (!_allSelectionsComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un grupo de cada tipo para cada asignatura'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (mounted) {
      Navigator.pop(context, selectedGroups);
    }
  }

  String getGroupLabel(String letter) {
    switch (letter) {
      case 'A': return 'Grupo de teoría';
      case 'B': return 'Grupo de problemas';
      case 'C': return 'Grupo de prácticas';
      case 'D': return 'Laboratorio';
      case 'X': return 'Teoría-Prácticas';
      case 'E': return 'Salidas de campo';
      default: return 'Grupo $letter';
    }
  }

  List<String> _getMissingTypesForSubject(String subjectCode) {
    final subject = subjects.firstWhere((s) => s['code'] == subjectCode);
    final groups = subject['classes'] as List;
    final requiredTypes = groups.map((g) => g['type'][0]).toSet();
    final selectedTypes = selectedGroups[subjectCode]?.keys.toSet() ?? {};

    return requiredTypes.difference(selectedTypes).map((type) => getGroupLabel(type)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selección de grupos', style: TextStyle(color: Colors.white)),
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
                  if (!_allSelectionsComplete)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        color: Colors.orange[50],
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Debes seleccionar un grupo de cada tipo para cada asignatura',
                                  style: TextStyle(color: Colors.orange[800]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        final missingTypes = _getMissingTypesForSubject(subject['code']);
                        Map<String, List<Map<String, dynamic>>> groupedClasses = {};

                        for (var group in subject['classes']) {
                          final type = group['type'];
                          final letter = type[0];
                          if (!groupedClasses.containsKey(letter)) {
                            groupedClasses[letter] = [];
                          }
                          groupedClasses[letter]?.add(group);
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
                                  // Nombre de la asignatura
                                  _buildInfoRow(
                                    icon: Icons.book,
                                    text: subject['name'] ?? 'No Name',
                                    isDarkMode: isDarkMode,
                                    isTitle: true,
                                  ),
                                  const SizedBox(height: 4),
                                  // Grado académico
                                  _buildInfoRow(
                                    icon: Icons.school,
                                    text: widget.subjectDegrees[subject['code']] ?? 'Grado no disponible',
                                    isDarkMode: isDarkMode,
                                    isTitle: false,
                                  ),
                                  const SizedBox(height: 12),
                                  if (missingTypes.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        'Faltan: ${missingTypes.join(', ')}',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ...groupedClasses.keys.map((letter) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          getGroupLabel(letter),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: groupedClasses[letter]!.map<Widget>((group) {
                                            final isSelected = selectedGroups[subject['code']]?[letter] == group['type'];
                                            return ChoiceChip(
                                              label: Text(
                                                group['type'],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isSelected 
                                                    ? (isDarkMode ? Colors.black : Colors.indigo)
                                                    : (isDarkMode ? Colors.yellow.shade700 : Colors.indigo),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              selected: isSelected,
                                              onSelected: (bool selected) {
                                                if (selected) {
                                                  setState(() {
                                                    selectedGroups[subject['code']]![letter] = group['type'];
                                                  });
                                                }
                                              },
                                              selectedColor: isDarkMode ? Colors.yellow.shade700 : Colors.indigo.shade100,
                                              backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                side: BorderSide(
                                                  color: isDarkMode ? Colors.grey.shade200 : Colors.indigo.shade300,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 10),
                                      ],
                                    );
                                  })
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

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required bool isDarkMode,
    required bool isTitle,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTitle ? 24 : 20,
          color: isDarkMode 
              ? Colors.yellow.shade700 : Colors.indigo.shade700,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTitle ? 18 : 14,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}