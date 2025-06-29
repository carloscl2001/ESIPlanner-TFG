import 'package:esiplanner/features/view_subjects/view_subjects_logic.dart';
import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final Map<String, dynamic> subject;
  final bool isDarkMode;
  final ViewSubjectsProfileLogic logic;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.isDarkMode,
    required this.logic,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final titleSize = isMobile ? 18.0 : 20.0; // Original: 20 (desktop)
    final bodySize = isMobile ? 14.0 : 16.0;  // Original: 16 (desktop)
    final iconSize = isMobile ? 24.0 : 30.0;  // Original: 30 (desktop)
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: isMobile ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gris1 : AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // Mantenemos igual
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre de asignatura
            Row(
              children: [
                Icon(
                  Icons.book_rounded,
                  color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                  size: iconSize,
                ),
                const SizedBox(width: 10), // Mantenemos igual
                Expanded(
                  child: Text(
                    subject['name'] ?? 'Asignatura',
                    style: TextStyle(
                      fontSize: titleSize, // Ajustado para mobile
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.blanco : AppColors.negro,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12), // Mantenemos igual
            
            // Código de asignatura
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10), // Mantenemos igual
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.gris2 : AppColors.azulClaro2,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                  width: 1,
                ),
              ),
              child: Text(
                subject['code'] ?? 'COD',
                style: TextStyle(
                  color: isDarkMode ? AppColors.amarilloClaro : AppColors.azulUCA,
                  fontWeight: FontWeight.w600,
                  fontSize: bodySize, // Ajustado para mobile
                ),
              ),
            ),
            
            const SizedBox(height: 12), // Mantenemos igual
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: () {
                // Primero obtenemos la lista de grupos como strings
                final groups = (subject['groups'] as List<dynamic>).map((g) => g.toString()).toList();
                // Luego la ordenamos
                groups.sort();
                // Finalmente mapeamos a widgets
                return groups.map((groupCode) {
                  final groupType = logic.getGroupType(groupCode);
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? AppColors.amarillo.withValues(alpha: 0.1) 
                          : AppColors.azulClaro2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getGroupIcon(groupCode),
                              size: isMobile ? 18.0 : 20.0,
                              color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              groupCode,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 14.0 : 16.0,
                                color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          groupType,
                          style: TextStyle(
                            fontSize: isMobile ? 12.0 : 16.0,
                            color: isDarkMode ? AppColors.blanco70 : AppColors.azulUCA,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              }(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGroupIcon(String groupCode) {
    if (groupCode.isEmpty) return Icons.group;
    final typeLetter = groupCode[0];
    switch (typeLetter) {
      case 'A': return Icons.menu_book; // Teoría
      case 'B': return Icons.calculate; // Problemas
      case 'C': return Icons.computer; // Prácticas informáticas
      case 'D': return Icons.science; // Laboratorio
      case 'E': return Icons.nature; // Salida de campo
      case 'X': return Icons.auto_stories; // Teoría-práctica
      default: return Icons.group;
    }
  }
}

class BuildEmptyCard extends StatelessWidget {
  const BuildEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.blanco70 : AppColors.negro54;
    final textColorButton = isDarkMode ? AppColors.negro : AppColors.blanco;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600), // Mantenemos igual
        margin: const EdgeInsets.all(24), // Mantenemos igual
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: isMobile ? 100.0 : 120.0, // Original desktop: 120
              color: textColor,
            ),
            const SizedBox(height: 24), // Mantenemos igual
            Text(
              'No has seleccionado asignaturas',
              style: TextStyle(
                fontSize: isMobile ? 24.0 : 28.0, // Original desktop: 28
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16), // Mantenemos igual
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40), // Mantenemos igual
              child: Text(
                'Selecciona tus asignaturas en la sección de perfil para comenzar a visualizar tu horario semanal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16.0 : 18.0, // Original desktop: 18
                  color: textColor,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32), // Mantenemos igual
            FilledButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, '/selectionSubjects');
                Navigator.pushNamed(context, '/home');
              },
              icon: Icon(
                Icons.edit_note_rounded,
                size: isMobile ? 20.0 : 24.0, // Original desktop: 24
              ),
              label: Text(
                'Seleccionar asignaturas',
                style: TextStyle(
                  color: textColorButton,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 14.0 : 16.0, // Original desktop: 16
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25), // Mantenemos igual
                backgroundColor: isDarkMode 
                    ? AppColors.amarillo.withValues(alpha: 0.8) 
                    : AppColors.azulUCA,
              ),
            ),
          ],
        ),
      ),
    );
  }
}