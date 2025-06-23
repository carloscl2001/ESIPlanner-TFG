import 'package:esiplanner/shared/app_colors.dart';
import 'package:esiplanner/shared/subject_colors.dart';
import 'package:flutter/material.dart';

class EventCardMyWeekDesktop extends StatefulWidget {
  final Map<String, dynamic> eventData;
  final String Function(String) getGroupLabel;
  final Color subjectColor;
  final bool isDarkMode;
  final bool isDesktop;
  final double estimatedLineHeight = 18.0;
  final double overflowThresholdHeight = 65.0;
  final bool isMyWeek;

  const EventCardMyWeekDesktop({
    super.key,
    required this.eventData,
    required this.getGroupLabel,
    required this.subjectColor,
    required this.isDarkMode,
    this.isDesktop = false,
    required this.isMyWeek,
  });

  @override
  State<EventCardMyWeekDesktop> createState() => _EventCardState();
}

class _EventCardState extends State<EventCardMyWeekDesktop> with SingleTickerProviderStateMixin {
  bool _isHoveredOrPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late double _hoverScaleFactor;

  @override
  void initState() {
    super.initState();

    _hoverScaleFactor = widget.isMyWeek ? 1.015 : 1.03;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: _hoverScaleFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

    final isDesktop = widget.isDesktop;
    final titleIconSize = isDesktop ? 30.0 : 24.0;
    final titleFontSize = isDesktop ? 26.0 : 20.0;
    final contentIconSize = isDesktop ? 20.0 : 16.0;
    final contentFontSize = isDesktop ? 18.0 : 14.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.book, color: widget.subjectColor, size: titleIconSize),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  subjectName, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: titleFontSize
                  )
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(_getGroupIcon(classType), color: widget.subjectColor, size: contentIconSize),
                    const SizedBox(width: 8),
                    Text(
                      '$classType - ${widget.getGroupLabel(classType[0])}', 
                      style: TextStyle(fontSize: contentFontSize)
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule_outlined, color: widget.subjectColor, size: contentIconSize),
                    const SizedBox(width: 8),
                    Text('$startTime - $endTime', style: TextStyle(fontSize: contentFontSize)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: widget.subjectColor, size: contentIconSize),
                    const SizedBox(width: 8),
                    Text('$location', style: TextStyle(fontSize: contentFontSize)),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar', style: TextStyle(fontSize: contentFontSize)),
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
    final location = event['location'] ?? 'No especificado';
    final isDesktop = widget.isDesktop;

    int estimatedLines = 1;
    if ('$classType - ${widget.getGroupLabel(classType[0])}'.isNotEmpty) estimatedLines++;
    if ('${event['start_hour']} - ${event['end_hour']}'.isNotEmpty) estimatedLines++;
    if (location.isNotEmpty) estimatedLines++;
    if (subjectName.length > 25) estimatedLines++;

    final hasEstimatedOverflow = estimatedLines * widget.estimatedLineHeight > widget.overflowThresholdHeight;
    final int maxLinesSubject = hasEstimatedOverflow ? 1 : 2;
    const int maxLinesOther = 1;

    final baseColor = SubjectColors.getCardBackgroundColor(widget.subjectColor, widget.isDarkMode);
    final effectColor = widget.isDarkMode 
        ? baseColor.withValues(alpha: 0.2)
        : Color.alphaBlend(AppColors.negro.withValues(alpha: 0.025), baseColor);

    final cardContent = Container(
      margin: const EdgeInsets.only(left: 2, right: 2, top: 1, bottom: 1),
      decoration: BoxDecoration(
        color: _isHoveredOrPressed ? effectColor : baseColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.subjectColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.negro.withAlpha(_isHoveredOrPressed ? 40 : 25),
            blurRadius: _isHoveredOrPressed ? 6 : 4,
            offset: Offset(0, _isHoveredOrPressed ? 3 : 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 8, top: 8, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subjectName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.isDarkMode ? AppColors.blanco : AppColors.negro,
                      fontSize: isDesktop ? 20 : 16,
                    ),
                    maxLines: maxLinesSubject,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(_getGroupIcon(classType), size: isDesktop ? 18 : 16, color: widget.subjectColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$classType - ${widget.getGroupLabel(classType[0])}',
                    style: TextStyle(
                      color: widget.isDarkMode ? AppColors.blanco70 : AppColors.negro87,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                    maxLines: maxLinesOther,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: isDesktop ? 18 : 16, color: widget.subjectColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${event['start_hour']} - ${event['end_hour']}',
                    style: TextStyle(
                      color: widget.isDarkMode ? AppColors.blanco70 : AppColors.negro87,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                    maxLines: maxLinesOther,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: isDesktop ? 18 : 16, color: widget.subjectColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(
                      color: widget.isDarkMode ? AppColors.blanco70 : AppColors.negro87,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                    maxLines: maxLinesOther,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (widget.isDesktop) {
      return MouseRegion(
        onEnter: (_) {
          setState(() => _isHoveredOrPressed = true);
          _controller.forward();
        },
        onExit: (_) {
          setState(() => _isHoveredOrPressed = false);
          _controller.reverse();
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showEventDetails(context),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: cardContent,
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: hasEstimatedOverflow ? () => _showEventDetails(context) : null,
        child: cardContent,
      );
    }
  }
}