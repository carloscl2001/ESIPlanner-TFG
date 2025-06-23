import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class ClassCards extends StatelessWidget {
  final String subjectName;
  final String classType;
  final Map<String, dynamic> event;
  final bool isOverlap;
  final bool isDesktop; // Nuevo parámetro para detectar pantallas grandes

  const ClassCards({
    super.key,
    required this.subjectName,
    required this.classType,
    required this.event,
    required this.isOverlap,
    this.isDesktop = false, // Valor por defecto false
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: isOverlap
            ? const BorderSide(
                color: Colors.red,
                width: 2.0, // Borde más grueso en desktop
              )
            : BorderSide.none,
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal:  0.0,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    AppColors.negro,
                    const Color.fromARGB(173, 44, 43, 43),
                  ]
                : [
                    AppColors.azulClaro2,
                    AppColors.blanco,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subjectName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? AppColors.blanco : AppColors.negro,
                ),
              ),
              SizedBox(height: 12),
              _buildRow(
                _getGroupIcon(classType), // Usamos la nueva función aquí
                classType,
                isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                isDarkMode ? AppColors.blanco : AppColors.negro,
              ),
              SizedBox(height: 8),
              _buildRow(
                Icons.access_time,
                '${event['start_hour']} - ${event['end_hour']}',
                isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                isDarkMode ? AppColors.blanco : AppColors.negro,
              ),
              SizedBox(height: 8),
              _buildRow(
                Icons.location_on,
                event['location'].toString(),
                isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                isDarkMode ? AppColors.blanco : AppColors.negro,
              ),
              if (isOverlap)
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: _buildRow(
                    Icons.warning,
                    'Este evento se solapa con otro',
                    Colors.red,
                    Colors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(
    IconData icon,
    String text,
    Color colorIcon,
    Color colorTexto,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: colorIcon,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colorTexto,
              fontWeight: FontWeight.normal,
              fontSize: null,
            ),
          ),
        ),
      ],
    );
  }
}