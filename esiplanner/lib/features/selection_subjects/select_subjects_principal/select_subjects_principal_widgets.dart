import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectSubjectsPrincipalWidgets {
  static void showAddSubjectsDialog({
    required BuildContext context,
    required List<String> availableDegrees,
    required Function(String) onDegreeSelected,
    required bool isDarkMode,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar grado de la asignatura'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableDegrees.length,
            itemBuilder: (context, index) {
              final degree = availableDegrees[index];
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.school_rounded,
                      color: isDarkMode ? AppColors.amarillo : AppColors.azulIntermedioUCA,
                    ),
                    title: Text(degree),
                    onTap: () {
                      Navigator.pop(context);
                      onDegreeSelected(degree);
                      HapticFeedback.lightImpact();
                    },
                  ),
                  if (index < availableDegrees.length - 1) const Divider(height: 1),
                ],
              );
            },
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static Widget buildSelectedSubjectCard({
    required BuildContext context,
    required String code,
    required String name,
    required String degree,
    required bool hasGroupsSelected,
    required VoidCallback onDelete,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 14, right: 2),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$code • $degree',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(150),
                      )
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          hasGroupsSelected ? Icons.check_circle : Icons.warning,
                          color: hasGroupsSelected
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasGroupsSelected
                              ? 'Grupos asignados'
                              : 'No hay grupos asignados',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: hasGroupsSelected
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildEmptySelectionCard(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.blanco70 : AppColors.negro54;
  
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 120,
              color: textColor,
            ),
            const SizedBox(height: 24),
            Text(
              'No has seleccionado asignaturas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pulsa el botón + para añadirlas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: textColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  

  static Widget buildManageGroupsButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required bool hasSelectedSubjects,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: hasSelectedSubjects ? onPressed : null,
          icon: const Icon(Icons.group),
          label: const Text('Asignar grupos'),
           iconAlignment: IconAlignment.end,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
            foregroundColor: isDarkMode ? AppColors.negro : AppColors.blanco,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class AddSubjectFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDarkMode;

  const AddSubjectFAB({
    super.key,
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
        foregroundColor: isDarkMode ? AppColors.negro : AppColors.blanco,
        hoverColor: isDarkMode 
            ? AppColors.amarilloOscuro// Color más claro en hover
            : AppColors.azulIntermedioUCA,
        child: const Icon(Icons.add), // ← child debe ser el último parámetro
      ),
    );
  }
}