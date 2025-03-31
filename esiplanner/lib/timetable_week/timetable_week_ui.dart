import 'package:flutter/material.dart';
import 'timetable_week_logic.dart';
import 'timetable_week_widgets.dart';

class WeekClassesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> events;
  final int selectedWeekIndex;
  final bool isDarkMode;
  final DateTime weekStartDate;

  const WeekClassesScreen({
    super.key,
    required this.events,
    required this.selectedWeekIndex,
    required this.isDarkMode,
    required this.weekStartDate,
  });

  @override
  Widget build(BuildContext context) {
    final logic = TimetableWeekLogic(
      events: events,
      selectedWeekIndex: selectedWeekIndex,
      weekStartDate: weekStartDate,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis clases de la semana'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          WeekHeader(logic: logic, isDarkMode: isDarkMode),
          WeekDaysHeader(logic: logic, isDarkMode: isDarkMode),
          Expanded(
            child: EventList(logic: logic, isDarkMode: isDarkMode),
          ),
        ],
      ),
    );
  }
}