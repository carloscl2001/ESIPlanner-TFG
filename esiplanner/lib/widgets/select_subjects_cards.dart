import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectSubjectsCards {
  static Widget buildDegreeDropdown({
  required BuildContext context,
  required List<String> availableDegrees,
  required Function(String) onDegreeSelected,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {}, // Feedback táctil (opcional)
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            dropdownColor: Theme.of(context).colorScheme.surface,
            icon: Icon(Icons.arrow_drop_down, 
                     color: Colors.indigo),
            iconSize: 28,
            decoration: InputDecoration(
              labelText: 'Seleccionar grado',
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 16,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(Icons.school, 
                             color: Colors.indigo),
            ),
            items: availableDegrees.map((degree) {
              return DropdownMenuItem(
                value: degree,
                child: Text(
                  degree,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (degree) {
              if (degree != null) {
                onDegreeSelected(degree);
                // Feedback de selección (opcional)
                HapticFeedback.lightImpact();
              }
            },
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            borderRadius: BorderRadius.circular(12),
            elevation: 4,
          ),
        ),
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
      onTap: () {}, // Puedes añadir funcionalidad si es necesario
      child: Padding(
        padding: const EdgeInsets.only(top:10, bottom: 10, left: 14, right: 2),
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
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 13,
                    ),
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
    return Center(
      child: Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_add,
                size: 64,
                color: Theme.of(context).disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Selecciona asignaturas de algún grado',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildManageGroupsButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required bool hasSelectedSubjects,
  }) {
    return Padding(
    padding: const EdgeInsets.all(16.0),
    child: ElevatedButton.icon(
      icon: const Icon(Icons.group, color: Colors.white), // Color del icono
      label: const Text(
        'Seleccionar Grupos',
        style: TextStyle(
          color: Colors.white, // Color del texto
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: hasSelectedSubjects ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigo, // Color de fondo del botón
        foregroundColor: Colors.white, // Color del texto e icono (afecta cuando no se especifica en el Text/Icon)
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    ),
  );
  }

  static Widget buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

}
