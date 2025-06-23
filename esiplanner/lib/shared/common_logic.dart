import 'package:intl/intl.dart';

// ========== CONSTANTES COMPARTIDAS ==========
const List<String> weekDays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie'];
const List<String> weekDaysFullName = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];

// ========== FUNCIONES COMPARTIDAS ==========

// 1. Gestión de tipos de grupos
String getGroupLabel(String letter) {
  switch (letter) {
    case 'A': return 'Teoría';
    case 'B': return 'Problemas';
    case 'C': return 'Prácticas informáticas';
    case 'D': return 'Laboratorio';
    case 'E': return 'Salida de campo';
    case 'X': return 'Teoría-práctica';
    default: return 'Clase de teoría-práctica';
  }
}

// 2. Gestión de fechas
DateTime getStartOfWeek(DateTime date) {
  return DateTime.utc(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
}

String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

bool isWeekend(DateTime date) {
  return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
}

String formatDateShort(DateTime date) {
  return DateFormat('dd MMMM', 'es_ES').format(date);
}

String getMonthName(int month) {
  const monthNames = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
  ];
  return monthNames[month - 1];
}

// 3. Gestión de asignaturas
Map<String, String> createSubjectMapping(List<Map<String, dynamic>> mappingList) {
  final mapping = <String, String>{};
  for (var item in mappingList) {
    final code = item['code']?.toString();
    final codeIcs = item['code_ics']?.toString();
    if (code != null && codeIcs != null) {
      mapping[code] = codeIcs;
    }
  }
  return mapping;
}

List<dynamic> filterClasses(List<dynamic>? classes, List<dynamic>? userTypes) {
  if (classes == null) return [];
  return classes.where((classData) {
    final classType = classData['group_code']?.toString();
    final types = (userTypes)?.cast<String>() ?? [];
    return classType != null && types.contains(classType);
  }).toList();
}

Future<List<Map<String, dynamic>>> fetchAndFilterSubjects({
  required List<dynamic> userSubjects,
  required Map<String, String> subjectMapping,
  required Future<Map<String, dynamic>> Function(String codeSubject) getSubjectData,
  void Function(String message)? onError,
}) async {
  List<Map<String, dynamic>> updatedSubjects = [];

  for (var subject in userSubjects) {
    try {
      final subjectCode = subject['code']?.toString();
      if (subjectCode == null) continue;

      final codeIcs = subjectMapping[subjectCode];
      if (codeIcs == null) {
        onError?.call('No se encontró mapeo para la asignatura: $subjectCode');
        continue;
      }

      final subjectData = await getSubjectData(codeIcs);
      final filteredClasses = filterClasses(subjectData['groups'], subject['groups_codes']);

      // Ordenar eventos dentro de cada clase
      for (var classData in filteredClasses) {
        classData['events'].sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      }

      // Ordenar clases por fecha del primer evento
      filteredClasses.sort((a, b) => DateTime.parse(a['events'][0]['date']).compareTo(DateTime.parse(b['events'][0]['date'])));

      updatedSubjects.add({
        'name': subjectData['name'] ?? subject['name'],
        'code': subject['code'],
        'code_ics': codeIcs,
        'groups': filteredClasses,
      });
    } catch (e) {
      onError?.call('Error procesando asignatura ${subject['code']}: $e');
    }
  }

  return updatedSubjects;
}

// 4. Gestión de eventos
Map<String, List<Map<String, dynamic>>> groupEventsByDate(List<Map<String, dynamic>> events) {
  final groupedEvents = <String, List<Map<String, dynamic>>>{};
  for (var event in events) {
    final eventDate = event['event']['date'].split(' ')[0];
    groupedEvents.putIfAbsent(eventDate, () => []).add(event);
  }
  return groupedEvents;
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