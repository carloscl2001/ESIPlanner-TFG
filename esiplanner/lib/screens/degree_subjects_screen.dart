import 'package:flutter/material.dart';
import '../services/subject_service.dart';
import '../widgets/degree_subjects_cards.dart'; // Importa el nuevo archivo

class DegreeSubjectsScreen extends StatefulWidget {
  final String degreeName;
  final List<String> initiallySelected;

  const DegreeSubjectsScreen({
    super.key,
    required this.degreeName,
    required this.initiallySelected,
  });

  @override
  State<DegreeSubjectsScreen> createState() => _DegreeSubjectsScreenState();
}

class _DegreeSubjectsScreenState extends State<DegreeSubjectsScreen> {
  late SubjectService subjectService;
  bool isLoading = true;
  List<Map<String, dynamic>> subjects = [];
  Set<String> selectedSubjects = {};

  @override
  void initState() {
    super.initState();
    subjectService = SubjectService();
    selectedSubjects = Set.from(widget.initiallySelected);
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final degreeData = await subjectService.getDegreeData(
        degreeName: widget.degreeName,
      );

      if (!mounted) return;

      if (degreeData['subjects'] != null) {
        List<Map<String, dynamic>> loadedSubjects = [];

        for (var subject in degreeData['subjects']) {
          final subjectData = await subjectService.getSubjectData(
            codeSubject: subject['code'],
          );
          
          if (!mounted) return;
          
          loadedSubjects.add({
            'name': subjectData['name'] ?? 'Sin nombre',
            'code': subject['code'],
          });
        }
        
        if (!mounted) return;
        
        setState(() {
          subjects = loadedSubjects;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        _showError('No se encontraron asignaturas');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _showError('Error al cargar asignaturas: $e');
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

  void _toggleSelection(String code) {
    setState(() {
      if (selectedSubjects.contains(code)) {
        selectedSubjects.remove(code);
      } else {
        selectedSubjects.add(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.degreeName),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => Navigator.pop(context, selectedSubjects.toList()),
            tooltip: 'Guardar selecciones',
          ),
        ],
      ),
      body: isLoading
          ? SubjectDegreeCards.buildLoadingIndicator()
          : subjects.isEmpty
              ? SubjectDegreeCards.buildErrorWidget(
                  'No hay asignaturas disponibles', 
                  context,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return SubjectDegreeCards.buildSubjectCard(
                      context: context,
                      name: subject['name'],
                      code: subject['code'],
                      isSelected: selectedSubjects.contains(subject['code']),
                      onTap: () => _toggleSelection(subject['code']),
                    );
                  },
                ),
    );
  }
}