import 'package:flutter/material.dart';
import '../services/subject_service.dart';
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
  Map<String, String> subjectDegrees = {}; // Para guardar el grado de cada asignatura

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
      _updateSelections(result, degree);
    }
  }

  void _updateSelections(List<String> newSelections, String degree) {
    setState(() {
      // Primero eliminamos asignaturas de este grado que ya no estén seleccionadas
      selectedSubjects.removeWhere((code) => 
        subjectDegrees[code] == degree && !newSelections.contains(code));
      
      // Luego agregamos las nuevas selecciones
      selectedSubjects.addAll(newSelections);
      
      // Actualizamos los grados de las asignaturas
      for (var code in newSelections) {
        subjectDegrees[code] = degree;
        if (!subjectNames.containsKey(code)) {
          subjectNames[code] = "Cargando...";
          _loadSubjectName(code);
        }
      }
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

  void _navigateToGroupSelection() {
    if (selectedSubjects.isEmpty) {
      _showError('Selecciona al menos una asignatura');
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selección de Asignaturas'),
        actions: [
          if (selectedSubjects.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Asignaturas Seleccionadas'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: selectedSubjects.map((code) => 
                        Text('${subjectNames[code]} ($code) - ${subjectDegrees[code]}')
                      ).toList(),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Selector de grados
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Seleccionar grado',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.school),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
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

          // Resumen y botón
          Expanded(
            child: Stack(
              children: [
                // Lista de asignaturas seleccionadas
                if (selectedSubjects.isNotEmpty)
                  ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: selectedSubjects.length,
                    itemBuilder: (context, index) {
                      final code = selectedSubjects.elementAt(index);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.book),
                          title: Text(subjectNames[code] ?? 'Cargando...'),
                          subtitle: Text('$code • ${subjectDegrees[code]}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                selectedSubjects.remove(code);
                                subjectNames.remove(code);
                                subjectDegrees.remove(code);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),

                // Mensaje cuando no hay selecciones
                if (selectedSubjects.isEmpty)
                  Center(
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
                  ),

                // Botón flotante para grupos
                if (selectedSubjects.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: FloatingActionButton.extended(
                      icon: const Icon(Icons.group),
                      label: const Text('SELECCIONAR GRUPOS'),
                      onPressed: _navigateToGroupSelection,
                      backgroundColor: theme.primaryColor,
                      foregroundColor: theme.colorScheme.onPrimary,
                      elevation: 4,
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