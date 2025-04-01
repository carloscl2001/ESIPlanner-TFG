import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subject_service.dart';
import '../providers/theme_provider.dart';
import 'degree_subjects_screen.dart';
import 'select_group_screen.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  late SubjectService subjectService;
  bool isLoading = true;
  List<String> availableDegrees = [];
  Set<String> selectedSubjects = {};
  Map<String, String> subjectNames = {};
  Map<String, bool> groupsSelected = {}; // Track if groups are selected for each subject

  @override
  void initState() {
    super.initState();
    subjectService = SubjectService();
    _loadDegrees();
  }

  Future<void> _loadDegrees() async {
    try {
      final degrees = await subjectService.getAllDegrees();
      setState(() {
        availableDegrees = degrees;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Error al cargar grados: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _navigateToDegreeSubjects(String degree) async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => DegreeSubjectsScreen(
          degreeName: degree,
          initiallySelected: selectedSubjects.toList(),
        ),
      ),
    );

    if (result != null) {
      _updateSelections(result);
    }
  }

  void _updateSelections(List<String> newSelections) {
    setState(() {
      selectedSubjects = Set.from(newSelections);
      // Initialize group selection status
      for (var code in selectedSubjects) {
        if (!groupsSelected.containsKey(code)) {
          groupsSelected[code] = false;
        }
        if (!subjectNames.containsKey(code)) {
          subjectNames[code] = "Cargando...";
          _loadSubjectName(code);
        }
      }
      // Remove deselected subjects
      subjectNames.removeWhere((key, _) => !selectedSubjects.contains(key));
      groupsSelected.removeWhere((key, _) => !selectedSubjects.contains(key));
    });
  }

  Future<void> _loadSubjectName(String code) async {
    try {
      final data = await subjectService.getSubjectData(codeSubject: code);
      if (mounted) {
        setState(() {
          subjectNames[code] = data['name'] ?? 'Sin nombre';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          subjectNames[code] = 'Error al cargar';
        });
      }
    }
  }

  void _navigateToGroupSelection() async {
    if (selectedSubjects.isEmpty) {
      _showError('Selecciona al menos una asignatura');
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectGroupsScreen(
          selectedSubjectCodes: selectedSubjects.toList(),
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        // Update group selection status
        for (var code in selectedSubjects) {
          groupsSelected[code] = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selección de Asignaturas'),
        actions: [
          if (selectedSubjects.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: _navigateToGroupSelection,
              tooltip: 'Seleccionar grupos',
            ),
        ],
      ),
      body: Column(
        children: [
          // Selector de grados
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Seleccionar grado',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.school),
                ),
                items: availableDegrees.map((degree) {
                  return DropdownMenuItem(
                    value: degree,
                    child: Text(degree),
                  );
                }).toList(),
                onChanged: (degree) => _navigateToDegreeSubjects(degree!),
              ),
            ),
          ),

          // Resumen de selección
          Expanded(
            child: selectedSubjects.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bookmark_add,
                          size: 64,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selecciona asignaturas de algún grado',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Asignaturas Seleccionadas (${selectedSubjects.length})',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: selectedSubjects.length,
                          itemBuilder: (context, index) {
                            final code = selectedSubjects.elementAt(index);
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: const Icon(Icons.book),
                                title: Text(subjectNames[code] ?? 'Cargando...'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(code),
                                    const SizedBox(height: 4),
                                    Text(
                                      groupsSelected[code] == true
                                          ? 'Grupos seleccionados ✓'
                                          : 'Grupos pendientes de selección',
                                      style: TextStyle(
                                        color: groupsSelected[code] == true
                                            ? Colors.green
                                            : Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      selectedSubjects.remove(code);
                                      subjectNames.remove(code);
                                      groupsSelected.remove(code);
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.group),
                          label: const Text('Gestionar Grupos'),
                          onPressed: _navigateToGroupSelection,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}