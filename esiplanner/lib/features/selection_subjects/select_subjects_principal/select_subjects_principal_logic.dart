import 'dart:ui';

import 'package:esiplanner/services/subject_service.dart';
import 'package:esiplanner/services/profile_service.dart';
import 'package:esiplanner/providers/auth_provider.dart';

class SubjectSelectionPrincipalLogic {
  final VoidCallback refreshUI;
  final Function(String) showError;
  final SubjectService subjectService;
  final AuthProvider authProvider;
  bool _isDisposed = false;

  bool isLoading = true;
  List<String> availableDegrees = [];
  Set<String> selectedSubjects = {};
  Map<String, String> subjectNames = {};
  Map<String, String> subjectDegrees = {};
  Map<String, bool> groupsSelected = {};
  Map<String, Map<String, String>> selectedGroupsMap = {};

  SubjectSelectionPrincipalLogic({
    required this.refreshUI,
    required this.showError,
    required this.subjectService,
    required this.authProvider,
  });

  Future<void> loadDegrees() async {
    try {
      final degrees = await subjectService.getNameAllDegrees();
      if (!_isDisposed) {
        availableDegrees = degrees;
        isLoading = false;
        refreshUI();
      }
    } catch (e) {
      if (!_isDisposed) {
        isLoading = false;
        refreshUI();
        showError('Error al cargar grados: $e');
      }
    }
  }

  Future<void> updateSelections(Map<String, dynamic> selectionData) async {
    if (_isDisposed) return;
    
    final codes = List<String>.from(selectionData['codes'] ?? []);
    final names = List<String>.from(selectionData['names'] ?? []);
    final degree = selectionData['degree'] as String;
    
    // Añadimos las nuevas asignaturas al conjunto existente
    selectedSubjects.addAll(codes);
    
    for (int i = 0; i < codes.length; i++) {
      final code = codes[i];
      final name = names[i];
      
      if (!groupsSelected.containsKey(code)) {
        groupsSelected[code] = false;
      }
      
      // Solo actualizamos nombre y grado si no existían previamente
      subjectNames.putIfAbsent(code, () => name);
      subjectDegrees.putIfAbsent(code, () => degree);
    }
    
    refreshUI();
  }

  Future<void> confirmSelections() async {
    if (_isDisposed) return;
    
    if (selectedSubjects.isEmpty) {
      showError('No hay asignaturas seleccionadas');
      return;
    }

    if (groupsSelected.values.any((selected) => !selected)) {
      showError('Algunas asignaturas no tienen grupos asignados');
      return;
    }

    final username = authProvider.username;
    if (username == null) {
      showError('Usuario no autenticado');
      return;
    }

    try {
      final selectedSubjectsData = selectedGroupsMap.entries.map((entry) {
        return {
          'code': entry.key,
          'groups_codes': entry.value.values.toList(),
        };
      }).toList();

      await ProfileService().updateSubjects(
        username: username,
        subjects: selectedSubjectsData,
      );
    } catch (e) {
      if (!_isDisposed) {
        showError('Error al confirmar: ${e.toString()}');
      }
    }
  }

  void resetSelection() {
    if (_isDisposed) return;
    selectedSubjects.clear();
    subjectNames.clear();
    subjectDegrees.clear();
    groupsSelected.clear();
    selectedGroupsMap.clear();
    refreshUI();
  }

  void dispose() {
    _isDisposed = true;
  }
}