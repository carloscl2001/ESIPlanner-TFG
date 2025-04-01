import 'package:flutter/material.dart';
import '../services/subject_service.dart';

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

      if (degreeData['subjects'] != null) {
        List<Map<String, dynamic>> loadedSubjects = [];

        for (var subject in degreeData['subjects']) {
          final subjectData = await subjectService.getSubjectData(
            codeSubject: subject['code'],
          );
          loadedSubjects.add({
            'name': subjectData['name'] ?? 'Sin nombre',
            'code': subject['code'],
          });
        }

        setState(() {
          subjects = loadedSubjects;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('No se encontraron asignaturas');
      }
    } catch (e) {
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
        backgroundColor: Colors.red,
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
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: CheckboxListTile(
                    title: Text(subject['name']),
                    subtitle: Text(subject['code']),
                    value: selectedSubjects.contains(subject['code']),
                    onChanged: (_) => _toggleSelection(subject['code']),
                    secondary: const Icon(Icons.book),
                    controlAffinity: ListTileControlAffinity.trailing,
                  ),
                );
              },
            ),
    );
  }
}