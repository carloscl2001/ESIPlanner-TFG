import 'package:esiplanner/shared/app_colors.dart';
import 'package:esiplanner/shared/subject_colors.dart';
import 'package:flutter/material.dart';

class EventCardTimetableWeek extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String Function(String) getGroupLabel;
  final Color subjectColor;
  final bool isDarkMode;
  final double estimatedLineHeight = 18.0;
  final double overflowThresholdHeight = 65.0;

  const EventCardTimetableWeek({
    super.key,
    required this.eventData,
    required this.getGroupLabel,
    required this.subjectColor,
    required this.isDarkMode,
  });

  @override
  State<EventCardTimetableWeek> createState() => _EventCardState();
}

class _EventCardState extends State<EventCardTimetableWeek> {
  bool _isPressed = false;

  IconData _getGroupIcon(String groupCode) {
    if (groupCode.isEmpty) return Icons.group;
    final typeLetter = groupCode[0];
    switch (typeLetter) {
      case 'A': return Icons.menu_book;
      case 'B': return Icons.calculate;
      case 'C': return Icons.computer;
      case 'D': return Icons.science;
      case 'E': return Icons.nature;
      case 'X': return Icons.auto_stories;
      default: return Icons.group;
    }
  }

  void _showEventDetails(BuildContext context) {
    final event = widget.eventData['event'];
    final classType = widget.eventData['classType'];
    final subjectName = widget.eventData['subjectName'];
    final location = event['location'] ?? 'No especificado';
    final startTime = event['start_hour'];
    final endTime = event['end_hour'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Expanded(
            child: Text(
              subjectName, 
              style: const TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 20
              )
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(_getGroupIcon(classType), color: widget.subjectColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '$classType - ${widget.getGroupLabel(classType[0])}', 
                      style: const TextStyle(fontSize: 14)
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule_outlined, color: widget.subjectColor, size: 16),
                    const SizedBox(width: 8),
                    Text('$startTime - $endTime', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: widget.subjectColor, size: 16),
                    const SizedBox(width: 8),
                    Text('$location', style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cerrar',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.subjectColor, // Usa el color de la asignatura
                  // O si prefieres un color fijo:
                  // color: Colors.blue, // Ejemplo con color azul
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.eventData['event'];
    final classType = widget.eventData['classType'];
    final location = event['location'] ?? '';

    // Obtener la segunda parte de la ubicación
    final locationParts = location.split(' ');
    final locationText = locationParts.length > 1 ? locationParts[1] : '';

    // Calcular si el contenido cabe
    const iconSize = 22.0;
    const textSize = 14.0;

    final baseColor = SubjectColors.getCardBackgroundColor(widget.subjectColor, widget.isDarkMode);
    final effectColor = widget.isDarkMode 
        ? baseColor.withAlpha(50)
        : Color.alphaBlend(AppColors.negro.withAlpha(10), baseColor);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () => _showEventDetails(context),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _isPressed ? effectColor : baseColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.subjectColor,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.negro.withAlpha(25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: LayoutBuilder(
  builder: (context, constraints) {
    final maxWidth = constraints.maxWidth;

    // Estimar ancho de texto
    final textPainter = TextPainter(
      text: TextSpan(
        text: locationText,
        style: TextStyle(
          fontSize: textSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    final textWidth = textPainter.size.width;
    const iconWidth = iconSize;
    const spacing = 8.0;

    final totalContentWidth = iconWidth + (locationText.isNotEmpty ? spacing + textWidth : 0);

    final fitsHorizontally = totalContentWidth <= maxWidth;

    if (!fitsHorizontally) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getGroupIcon(classType),
            size: iconSize,
            color: widget.subjectColor,
          ),
          if (locationText.isNotEmpty) ...[
            const SizedBox(height: spacing),
            Text(
              locationText,
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.bold,
                color: widget.isDarkMode
                    ? AppColors.blanco70
                    : AppColors.negro87,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  },
),

      ),
    );
  }
}