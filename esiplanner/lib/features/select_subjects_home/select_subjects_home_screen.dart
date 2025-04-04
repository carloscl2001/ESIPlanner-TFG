import 'package:flutter/material.dart';
import '../../services/subject_service.dart';
import '../select_subjects_degree/select_subjects_degree_screen.dart';
import '../select_groups/select_group_screen.dart';
import 'package:esiplanner/widgets/select_subjects_cards.dart';

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
  Map<String, String> subjectDegrees = {};
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
      _updateSelections(result, degree);
    }
  }

  void _updateSelections(List<String> newSelections, String degree) {
    setState(() {
      selectedSubjects = Set.from(newSelections);
      for (var code in selectedSubjects) {
        if (!groupsSelected.containsKey(code)) {
          groupsSelected[code] = false;
        }
        if (!subjectNames.containsKey(code)) {
          subjectNames[code] = "Cargando...";
          subjectDegrees[code] = degree;
          _loadSubjectName(code);
        }
      }
      subjectNames.removeWhere((key, _) => !selectedSubjects.contains(key));
      subjectDegrees.removeWhere((key, _) => !selectedSubjects.contains(key));
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

  void _showSelectionInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guía de selección de asignaturas'),
        contentPadding: const EdgeInsets.all(16),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionStep(1, 'Selecciona un grado académico de la lista desplegable'),
              _buildInstructionStep(2, 'Marca las asignaturas que deseas cursar de ese grado'),
              _buildInstructionStep(3, 'Asigna grupos específicos para cada asignatura '),
              const SizedBox(height: 16),
              Text('* Repite los puntos 1 y 2, en caso de cursar asignaturas de grados diferentes', 
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

Widget _buildInstructionStep(int step, String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.indigo,
          child: Text('$step', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

  void _navigateToGroupSelection() async {
    if (selectedSubjects.isEmpty) {
      _showError('Selecciona al menos una asignatura');
      return;
    }

    final result = await Navigator.push<Map<String, bool>>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectGroupsScreen(
          selectedSubjectCodes: selectedSubjects.toList(),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        result.forEach((code, hasGroups) {
          groupsSelected[code] = hasGroups;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selección de asignaturas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showSelectionInstructions,
            tooltip: 'Instrucciones',
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
                        'Asignaturas seleccionadas (${selectedSubjects.length})',
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
                              degree: subjectDegrees[code] ?? 'Grado no disponible',
                              hasGroupsSelected: groupsSelected[code] ?? false,
                              onDelete: () {
                                setState(() {
                                  selectedSubjects.remove(code);
                                  subjectNames.remove(code);
                                  subjectDegrees.remove(code);
                                  groupsSelected.remove(code);
                                });
                              },
                            );
                          },
                        ),
                      ),
                      if (groupsSelected.values.any((selected) => !selected))
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