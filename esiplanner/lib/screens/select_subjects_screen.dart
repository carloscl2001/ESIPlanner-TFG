import 'package:flutter/material.dart';
import '../services/subject_service.dart';
import 'degree_subjects_screen.dart';
import 'select_group_screen.dart';
import 'package:esiplanner/widgets/select_subjects_cards.dart'; // Importa el nuevo archivo

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
  Map<String, bool> groupsSelected = {};

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
        backgroundColor: Theme.of(context).colorScheme.error,
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
      for (var code in selectedSubjects) {
        if (!groupsSelected.containsKey(code)) {
          groupsSelected[code] = false;
        }
        if (!subjectNames.containsKey(code)) {
          subjectNames[code] = "Cargando...";
          _loadSubjectName(code);
        }
      }
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
        for (var code in selectedSubjects) {
          groupsSelected[code] = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          SelectSubjectsCards.buildDegreeDropdown(
            context: context,
            availableDegrees: availableDegrees,
            onDegreeSelected: _navigateToDegreeSubjects,
          ),
          Expanded(
            child: selectedSubjects.isEmpty
                ? SelectSubjectsCards.buildEmptySelectionCard(context)
                : Column(
                    children: [
                      SelectSubjectsCards.buildSectionTitle(
                        context,
                        'Asignaturas Seleccionadas (${selectedSubjects.length})',
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: selectedSubjects.length,
                          itemBuilder: (context, index) {
                            final code = selectedSubjects.elementAt(index);
                            return SelectSubjectsCards.buildSelectedSubjectCard(
                              context: context,
                              code: code,
                              name: subjectNames[code] ?? 'Cargando...',
                              hasGroupsSelected: groupsSelected[code] ?? false,
                              onDelete: () {
                                setState(() {
                                  selectedSubjects.remove(code);
                                  subjectNames.remove(code);
                                  groupsSelected.remove(code);
                                });
                              },
                            );
                          },
                        ),
                      ),
                      SelectSubjectsCards.buildManageGroupsButton(
                        context: context,
                        onPressed: _navigateToGroupSelection,
                        hasSelectedSubjects: selectedSubjects.isNotEmpty,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}