import 'package:flutter/material.dart';

class SelectSubjectsCards {
  static Widget buildDegreeDropdown({
    required BuildContext context,
    required List<String> availableDegrees,
    required Function(String) onDegreeSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Seleccionar grado',
              border: InputBorder.none,
              prefixIcon: Icon(Icons.school, color: Theme.of(context).primaryColor),
            ),
            items: availableDegrees.map((degree) {
              return DropdownMenuItem(
                value: degree,
                child: Text(
                  degree,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
            }).toList(),
            onChanged: (degree) => onDegreeSelected(degree!),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }

  static Widget buildSelectedSubjectCard({
    required BuildContext context,
    required String code,
    required String name,
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
        borderRadius: BorderRadius.circular(16),
        onTap: () {}, // Puedes añadir funcionalidad si es necesario
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 2),
          child: Row(
            children: [
              Icon(
                Icons.book,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                      
                    ),
                    const SizedBox(height: 4),
                    Text(
                      code,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasGroupsSelected ? 'Grupos seleccionados ✓' : 'Grupos pendientes de selección',
                      style: TextStyle(
                        color: hasGroupsSelected ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
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
        icon: const Icon(Icons.group),
        label: const Text('Gestionar Grupos'),
        onPressed: hasSelectedSubjects ? onPressed : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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