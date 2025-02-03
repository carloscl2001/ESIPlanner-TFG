import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ClassCards extends StatelessWidget {
  final String subjectName;
  final String classType;
  final Map<String, dynamic> event;
  final bool isOverlap;

  const ClassCards({
    super.key,
    required this.subjectName,
    required this.classType,
    required this.event,
    required this.isOverlap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: isOverlap
            ? const BorderSide(color: Colors.red, width: 2.0) // Borde rojo para solapamientos
            : BorderSide.none,
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                  ? [Colors.grey.shade900, Colors.grey.shade900] // Degradado oscuro
                  : [Colors.indigo.shade50, Colors.white], // Degradado clarodado claro
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subjectName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.indigo.shade700,
                ),
              ),
              const SizedBox(height: 12),
              _buildRow(Icons.school, 'Tipo de clase: $classType', isDarkMode ? Colors.white : Colors.indigo.shade700,),
              const SizedBox(height: 8),
              _buildRow(Icons.access_time, '${event['start_hour']} - ${event['end_hour']}', isDarkMode ? Colors.white : Colors.indigo.shade700,),
              const SizedBox(height: 8),
              _buildRow(Icons.location_on, event['location'].toString(), isDarkMode ? Colors.white : Colors.indigo.shade700,),
              if (isOverlap)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: _buildRow(Icons.warning, 'Este evento se solapa con otro', Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
