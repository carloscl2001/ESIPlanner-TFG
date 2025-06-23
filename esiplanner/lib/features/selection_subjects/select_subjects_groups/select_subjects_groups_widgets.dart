import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'select_subjects_groups_logic.dart';

class SelectGroupsContent extends StatelessWidget {
  final bool isDarkMode;
  final bool requireAllTypes;
  final bool oneGroupPerType;

  const SelectGroupsContent({
    super.key,
    required this.isDarkMode,
    required this.requireAllTypes,
    required this.oneGroupPerType,
  });

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<SelectGroupsLogic>(context, listen: true);

    return Column(
      children: <Widget>[
        if (logic.errorMessage.isNotEmpty) ...[
          Text(
            logic.errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
        if (requireAllTypes && !logic.allSelectionsComplete)
          SelectionWarning(isDarkMode: isDarkMode),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: logic.subjects.length,
            itemBuilder: (context, index) {
              final subject = logic.subjects[index];
              final missingTypes = requireAllTypes 
                  ? logic.getMissingTypesForSubject(subject['code']).cast<String>()
                  : <String>[];
              
              Map<String, List<Map<String, dynamic>>> groupedClasses = {};
    
              for (var group in subject['groups']) {
                final type = group['group_code'];
                final letter = type[0];
                if (!groupedClasses.containsKey(letter)) {
                  groupedClasses[letter] = [];
                }
                groupedClasses[letter]?.add(group);
              }
    
              return SubjectGroupCard(
                subject: subject,
                groupedClasses: groupedClasses,
                missingTypes: missingTypes,
                isDarkMode: isDarkMode,
                subjectDegrees: logic.subjectDegrees,
                requireAllTypes: requireAllTypes,
                oneGroupPerType: oneGroupPerType,
              );
            },
          ),
        ),
      ],
    );
  }
}

class SettingsDialog extends StatefulWidget {
  final bool requireAllTypes;
  final bool oneGroupPerType;
  final Function(bool, bool, {bool forceClean}) onSettingsChanged;

  const SettingsDialog({
    super.key,
    required this.requireAllTypes,
    required this.oneGroupPerType,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late bool tempRequireAll;
  late bool tempOnePerType;

  @override
  void initState() {
    super.initState();
    tempRequireAll = widget.requireAllTypes;
    tempOnePerType = widget.oneGroupPerType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar restricciones'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SwitchListTile(
            title: const Text('Seleccionar todos los tipos de clases'),
            value: tempRequireAll,
            onChanged: (value) {
              setState(() {
                tempRequireAll = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Seleccionar solo un grupo por cada tipo de clase'), 
            value: tempOnePerType,
            onChanged: (value) {
              setState(() {
                tempOnePerType = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final wasDisabled = !widget.oneGroupPerType;
            final enablingNow = tempOnePerType;
            
            widget.onSettingsChanged(
              tempRequireAll, 
              tempOnePerType,
              forceClean: wasDisabled && enablingNow,
            );
            Navigator.pop(context);
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDarkMode;

  const SaveButton({
    super.key,
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Guardar selecciones'),
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
}

class SelectionWarning extends StatelessWidget {
  final bool isDarkMode;

  const SelectionWarning({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Card(
        color: isDarkMode ? AppColors.amarillo.withAlpha(229) : Colors.orange[50],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.warning, color: isDarkMode ? AppColors.blanco: Colors.orange[800]),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'No has completado todas las selecciones requeridas',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubjectGroupCard extends StatelessWidget {
  final Map<String, dynamic> subject;
  final Map<String, List<Map<String, dynamic>>> groupedClasses;
  final List<String> missingTypes;
  final bool isDarkMode;
  final Map<String, String> subjectDegrees;
  final bool requireAllTypes;
  final bool oneGroupPerType;

  const SubjectGroupCard({
    super.key,
    required this.subject,
    required this.groupedClasses,
    required this.missingTypes,
    required this.isDarkMode,
    required this.subjectDegrees,
    required this.requireAllTypes,
    required this.oneGroupPerType,
  });

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

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<SelectGroupsLogic>(context, listen: true);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [AppColors.negro, Colors.grey.shade900]
                : [AppColors.azulClaro2, AppColors.blanco],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InfoRow(
                icon: Icons.book,
                text: subject['name'] ?? 'No Name',
                isDarkMode: isDarkMode,
                isTitle: true,
              ),
              const SizedBox(height: 4),
              InfoRow(
                icon: Icons.school,
                text: subjectDegrees[subject['code']] ?? 'Grado no disponible',
                isDarkMode: isDarkMode,
                isTitle: false,
              ),
              const SizedBox(height: 4),
              InfoRow(
                icon: Icons.code_rounded,
                text: 'Código: ${subject['code']}',
                isDarkMode: isDarkMode,
                isTitle: false,
              ),
              // const SizedBox(height: 4),
              // InfoRow(
              //   icon: Icons.code_rounded,
              //   text: 'Código ICS: ${subject['code_ics'] ?? 'N/A'}',
              //   isDarkMode: isDarkMode,
              //   isTitle: false,
              // ),
              const SizedBox(height: 12),
              if (requireAllTypes && missingTypes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Falta por seleccionar: ${missingTypes.join(', ')}',
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ...groupedClasses.keys.map((letter) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Icon(
                          _getGroupIcon(letter),
                          color: isDarkMode ? AppColors.amarillo : AppColors.azulIntermedioUCA,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${logic.getGroupLabel(letter)}${requireAllTypes ? '' : ' (Opcional)'}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDarkMode ? AppColors.blanco : AppColors.negro,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: groupedClasses[letter]!.map<Widget>((group) {
                        final groupType = group['group_code'] as String;
                        final isSelected = logic.isGroupSelected(subject['code'], groupType);
                        
                        return GestureDetector(
                          onTap: () => logic.toggleGroupSelection(subject['code'], groupType),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDarkMode ? AppColors.amarillo : AppColors.azulClaroUCA1)
                                  : (isDarkMode ? Colors.grey.shade800 : AppColors.blanco),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode ? Colors.grey.shade200 : AppColors.azulIntermedioUCA,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getGroupIcon(groupType),
                                  size: 16,
                                  color: isSelected 
                                      ? (isDarkMode ? AppColors.negro : AppColors.azulIntermedioUCA)
                                      : (isDarkMode ? AppColors.blanco : AppColors.azulIntermedioUCA),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  groupType,
                                  style: TextStyle(
                                    color: isSelected 
                                        ? (isDarkMode ? AppColors.negro : AppColors.azulIntermedioUCA)
                                        : (isDarkMode ? AppColors.blanco : AppColors.azulIntermedioUCA),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isSelected && logic.oneGroupPerType)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: isDarkMode ? AppColors.negro : AppColors.azulIntermedioUCA,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDarkMode;
  final bool isTitle;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    required this.isDarkMode,
    required this.isTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: isTitle ? 24 : 20,
          color: isDarkMode 
              ? AppColors.amarillo 
              : AppColors.azulIntermedioUCA,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTitle ? 20 : 14,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
              color: isDarkMode ? AppColors.blanco : AppColors.negro,
            ),
          ),
        ),
      ],
    );
  }
}