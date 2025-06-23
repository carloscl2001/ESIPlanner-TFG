import 'package:esiplanner/shared/app_colors.dart';
import 'package:esiplanner/shared/subject_colors.dart';
import 'package:flutter/material.dart';

class EventCardMyWeekMobile extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String Function(String) getGroupLabel;
  final Color subjectColor;
  final bool isDarkMode;
  final double estimatedLineHeight = 18.0;
  final double overflowThresholdHeight = 65.0;

  const EventCardMyWeekMobile({
    super.key,
    required this.eventData,
    required this.getGroupLabel,
    required this.subjectColor,
    required this.isDarkMode,
  });

  @override
  State<EventCardMyWeekMobile> createState() => _EventCardState();
}

class _EventCardState extends State<EventCardMyWeekMobile> {
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
    final subjectName = widget.eventData['subjectName'];
    final location = event['location'] ?? '';

    // Obtener la segunda parte de la ubicación
    final locationParts = location.split(' ');
    final locationText = locationParts.length > 1 ? locationParts[1] : location;

    // Constantes de diseño
    const subjectTextSize = 15.0;
    const iconSize = 24.0;
    const groupTextSize = 12.0;
    const locationTextSize = 12.0;
    const locationIconSize = 22.0;
    const verticalSpacing = 6.0;
    const horizontalPadding = 4.0;
    const maxLinesForSubject = 2;

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
            final maxWidth = constraints.maxWidth - (2 * horizontalPadding);

            // Calcular si cabe el grupo junto al icono
            final groupText = classType;
            final groupTextWidth = _calculateTextWidth(groupText, groupTextSize, FontWeight.bold);
            const iconWithPaddingWidth = iconSize + 8;
            final groupFits = (iconWithPaddingWidth + groupTextWidth) <= maxWidth;

            // Calcular si cabe el icono de ubicación + texto
            final locationTextWidth = _calculateTextWidth(locationText, locationTextSize, FontWeight.bold);
            final locationWithIconWidth = locationTextWidth + locationIconSize + 8;
            final locationFits = locationText.isNotEmpty && (locationWithIconWidth <= maxWidth);

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
                horizontal: horizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nombre de la asignatura
                  SizedBox(
                    width: maxWidth,
                    child: Text(
                      subjectName,
                      style: TextStyle(
                        fontSize: subjectTextSize,
                        fontWeight: FontWeight.bold,
                        color: widget.isDarkMode ? AppColors.blanco : AppColors.negro,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: maxLinesForSubject,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // Icono y grupo
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getGroupIcon(classType),
                        size: iconSize,
                        color: widget.subjectColor,
                      ),
                      if (groupFits) ...[
                        SizedBox(width: 6),
                        Text(
                          groupText,
                          style: TextStyle(
                            fontSize: groupTextSize,
                            fontWeight: FontWeight.w700,
                            color: widget.isDarkMode ? AppColors.blanco70 : AppColors.negro87,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: verticalSpacing),

                  // Ubicación con icono (si cabe)
                  if (locationFits)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: locationIconSize,
                          color: widget.subjectColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          locationText,
                          style: TextStyle(
                            fontSize: locationTextSize,
                            fontWeight: FontWeight.w700,
                            color: widget.isDarkMode ? AppColors.blanco70 : AppColors.negro87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    )
                  else if (locationText.isNotEmpty)
                    Text(
                      locationText,
                      style: TextStyle(
                        fontSize: locationTextSize,
                        fontWeight: FontWeight.w700,
                        color: widget.isDarkMode ? AppColors.blanco70 : AppColors.negro87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Función auxiliar para calcular ancho de texto
  double _calculateTextWidth(String text, double fontSize, FontWeight fontWeight) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size.width;
  }
}