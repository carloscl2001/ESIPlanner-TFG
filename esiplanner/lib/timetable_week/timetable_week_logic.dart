
import 'package:intl/intl.dart';

class TimetableWeekLogic {
  final List<Map<String, dynamic>> events;
  final int selectedWeekIndex;
  final DateTime weekStartDate;

  TimetableWeekLogic({
    required this.events,
    required this.selectedWeekIndex,
    required this.weekStartDate,
  });

  Map<String, List<Map<String, dynamic>>> groupEventsByDate() {
    final groupedByDate = <String, List<Map<String, dynamic>>>{};
    for (var eventData in events) {
      final eventDate = eventData['event']['date'];
      groupedByDate.putIfAbsent(eventDate, () => []).add(eventData);
    }
    return groupedByDate;
  }

  int sortEventsByTime(Map<String, dynamic> a, Map<String, dynamic> b) {
    final timeA = DateTime.parse('${a['event']['date']} ${a['event']['start_hour']}');
    final timeB = DateTime.parse('${b['event']['date']} ${b['event']['start_hour']}');
    return timeA.compareTo(timeB);
  }

  List<bool> calculateOverlappingEvents(List<Map<String, dynamic>> events) {
    final isOverlapping = List<bool>.filled(events.length, false);
    for (int i = 0; i < events.length - 1; i++) {
      final endTimeCurrent = DateTime.parse('${events[i]['event']['date']} ${events[i]['event']['end_hour']}');
      final startTimeNext = DateTime.parse('${events[i + 1]['event']['date']} ${events[i + 1]['event']['start_hour']}');

      if (endTimeCurrent.isAfter(startTimeNext)) {
        isOverlapping[i] = true;
        isOverlapping[i + 1] = true;
      }
    }
    return isOverlapping;
  }

  String formatDateToFullDate(DateTime date) {
    final formattedDate = DateFormat('EEEE', 'es_ES').format(date);
    return _capitalize(formattedDate);
  }

  String getGroupLabel(String letter) {
    switch (letter) {
      case 'A': return 'Clase de teoría';
      case 'B': return 'Clase de problemas';
      case 'C': return 'Clase de prácticas informáticas';
      case 'D': return 'Clase de laboratorio';
      case 'X': return 'Clase de teoría-práctica';
      default: return 'Clase de teoría-práctica';
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  DateTime getStartOfWeek() {
    final localDate = DateTime.utc(weekStartDate.year, weekStartDate.month, weekStartDate.day);
    return localDate.subtract(Duration(days: localDate.weekday - 1));
  }
}