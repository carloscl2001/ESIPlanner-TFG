import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/class_cards.dart';
import '../providers/theme_provider.dart'; // Importa el ThemeProvider

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late ProfileService profileService;
  late SubjectService subjectService;

  bool isLoading = true;
  List<Map<String, dynamic>> subjects = [];
  String errorMessage = '';
  String? selectedDay; // Día seleccionado (lunes, martes, etc.)

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    subjectService = SubjectService();
    selectedDay = _getCurrentWeekday(); // Seleccionar el día actual
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final String? username = Provider.of<AuthProvider>(context, listen: false).username;

    if (username == null) {
      if (mounted) {
        setState(() {
          errorMessage = 'Usuario no autenticado';
          isLoading = false;
        });
      }
      return;
    }

    try {
      final profileData = await profileService.getProfileData(username: username);

      final degree = profileData["degree"];
      final List<dynamic> userSubjects = profileData["subjects"] ?? [];

      if (degree != null && userSubjects.isNotEmpty) {
        List<Map<String, dynamic>> updatedSubjects = [];

        for (var subject in userSubjects) {
          final subjectData = await subjectService.getSubjectData(codeSubject: subject['code']);

          // Verificar los tipos de datos
          print('Tipos del usuario: ${subject['types']}');
          print('Tipo de subject[types]: ${subject['types'].runtimeType}');

          // Filtrar las clases según los tipos del usuario
          final List<dynamic> filteredClasses = subjectData['classes']
              .where((classData) {
                // Verificar si 'type' está presente en classData
                if (classData.containsKey('type')) {
                  final classType = classData['type'].toString(); // Asegurarse de que es una cadena
                  print('Tipo de classData[type]: $classType');
                  final bool isTypeMatching = subject['types'].contains(classType);
                  print('¿Tipo coincide? $isTypeMatching (Usuario: ${subject['types']}, Clase: $classType)');
                  return isTypeMatching;
                } else {
                  print('El campo "type" no está presente en classData');
                  return false; // Si no tiene 'type', no se incluye en los resultados
                }
              })
              .toList();

          // Ordenar los eventos de cada clase por fecha
          for (var classData in filteredClasses) {
            classData['events'].sort((a, b) {
              DateTime dateA = DateTime.parse(a['date']);
              DateTime dateB = DateTime.parse(b['date']);
              return dateA.compareTo(dateB);
            });
          }

          // Ordenar las clases dentro de la asignatura por el primer evento de cada clase
          filteredClasses.sort((a, b) {
            DateTime dateA = DateTime.parse(a['events'][0]['date']);
            DateTime dateB = DateTime.parse(b['events'][0]['date']);
            return dateA.compareTo(dateB);
          });

          updatedSubjects.add({
            'name': subjectData['name'] ?? subject['name'],
            'code': subject['code'],
            'classes': filteredClasses, // Usar solo las clases filtradas
          });
        }

        if (mounted) {
          setState(() {
            subjects = updatedSubjects;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            errorMessage = degree == null
                ? 'No se encontró el grado en los datos del perfil'
                : 'El usuario no tiene asignaturas';
            isLoading = false;
          });
        }
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error al obtener los datos: $error';
          isLoading = false;
        });
      }
    }
  }

  String getGroupLabel(String letter) {
    switch (letter) {
      case 'A':
        return 'Clase de teoría';
      case 'B':
        return 'Clase de problemas';
      case 'C':
        return 'Clase de prácticas informáticas';
      case 'D':
        return 'Clase de laboratorio';
      case 'X':
        return 'Clase de teoríco-práctica';
      default:
        return 'Clase de teoríco-práctica';
    }
  }

  // Función para obtener el inicio de la semana (lunes)
  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Función para obtener el fin de la semana (domingo)
  DateTime _endOfWeek(DateTime date) {
    return date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
  }

  // Lista de días de la semana (lunes a viernes)
  final List<String> weekDays = ['L', 'M', 'X', 'J', 'V'];

  // Obtener las fechas de la semana actual
  List<String> getWeekDates() {
    final now = DateTime.now();
    final startOfWeek = _startOfWeek(now);
    return List.generate(7, (index) {
      final date = startOfWeek.add(Duration(days: index));
      return date.day.toString();
    });
  }

  String _getCurrentWeekday() {
    final now = DateTime.now();
    final int weekdayIndex = now.weekday - 1; // Convertir a índice (0 = lunes, 4 = viernes)
    return (weekdayIndex >= 0 && weekdayIndex < weekDays.length) ? weekDays[weekdayIndex] : 'L';
  }

 @override
Widget build(BuildContext context) {
  final themeProvider = Provider.of<ThemeProvider>(context); // Obtén el ThemeProvider
  final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

  final weekDates = getWeekDates();
  final now = DateTime.now();
  final monthYear = '${_getMonthName(now.month)} ${now.year}'; // Obtener el nombre del mes y el año
  

  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'Tus clases esta semana',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.indigo, // Color de la barra de navegación
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  monthYear,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                if (errorMessage.isNotEmpty) ...[
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
                // Mostrar días de la semana y fechas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(weekDays.length, (index) {
                    final day = weekDays[index];
                    final date = weekDates[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDay = day; // Seleccionar el día
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedDay == day 
                            ? (isDarkMode ? Colors.yellow.shade700 : Colors.indigo) 
                            : (isDarkMode ? Colors.grey.shade900 : Colors.indigo.shade50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              day,
                              style: TextStyle(
                                color: selectedDay == day 
                                ? (isDarkMode ? Colors.black : Colors.white) 
                                : (isDarkMode ? Colors.white : Colors.black),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              date,
                              style: TextStyle(
                                color: selectedDay == day 
                                  ? (isDarkMode ? Colors.black : Colors.white) 
                                  : (isDarkMode ? Colors.white : Colors.black),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildEventList(),
                ),
              ],
            ),
          ),
  );
}
String _getMonthYearRange(DateTime startOfWeek, DateTime endOfWeek) {
  final startMonth = _getMonthName(startOfWeek.month);
  final startYear = startOfWeek.year;
  final endMonth = _getMonthName(endOfWeek.month);
  final endYear = endOfWeek.year;

  if (startMonth == endMonth && startYear == endYear) {
    return '$startMonth $startYear'; // Semana dentro del mismo mes y año
  } else {
    return '$startMonth $startYear - $endMonth $endYear'; // Semana que abarca dos meses/años
  }
}

String _getMonthName(int month) {
  switch (month) {
    case 1:
      return 'Enero';
    case 2:
      return 'Febrero';
    case 3:
      return 'Marzo';
    case 4:
      return 'Abril';
    case 5:
      return 'Mayo';
    case 6:
      return 'Junio';
    case 7:
      return 'Julio';
    case 8:
      return 'Agosto';
    case 9:
      return 'Septiembre';
    case 10:
      return 'Octubre';
    case 11:
      return 'Noviembre';
    case 12:
      return 'Diciembre';
    default:
      return '';
  }
}
  Widget _buildEventList() {
    // Obtener el inicio y el fin de la semana actual
    final now = DateTime.now();
    final startOfWeek = _startOfWeek(now);
    final endOfWeek = _endOfWeek(now);

    // Recopilar todos los eventos de todas las asignaturas
    List<Map<String, dynamic>> allEvents = [];
    for (var subject in subjects) {
      for (var classData in subject['classes']) {
        for (var event in classData['events']) {
          final eventDate = DateTime.parse(event['date']);
          if (eventDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              eventDate.isBefore(endOfWeek.add(const Duration(days: 1)))) {
            allEvents.add({
              'subjectName': subject['name'] ?? 'No Name',
              'classType': classData['type'] ?? 'No disponible',
              'event': event,
            });
          }
        }
      }
    }

    // Filtrar eventos por día seleccionado
    if (selectedDay != null) {
      final selectedDayIndex = weekDays.indexOf(selectedDay!);
      final selectedDate = _startOfWeek(now).add(Duration(days: selectedDayIndex));

      allEvents = allEvents.where((eventData) {
        final eventDate = DateTime.parse(eventData['event']['date']);
        return eventDate.year == selectedDate.year &&
            eventDate.month == selectedDate.month &&
            eventDate.day == selectedDate.day;
      }).toList();
    }

    // Agrupar los eventos por fecha
    Map<String, List<Map<String, dynamic>>> groupedByDate = {};
    for (var eventData in allEvents) {
      final eventDate = eventData['event']['date'];

      if (!groupedByDate.containsKey(eventDate)) {
        groupedByDate[eventDate] = [];
      }

      groupedByDate[eventDate]!.add(eventData);
    }

    // Ordenar los eventos por hora dentro de cada fecha
    groupedByDate.forEach((date, events) {
      events.sort((a, b) {
        DateTime timeA = DateTime.parse('${a['event']['date']} ${a['event']['start_hour']}');
        DateTime timeB = DateTime.parse('${b['event']['date']} ${b['event']['start_hour']}');
        return timeA.compareTo(timeB);
      });
    });

    // Ordenar las fechas
    var sortedDates = groupedByDate.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events = groupedByDate[date]!;

        // Verificar solapamientos
        List<bool> isOverlapping = List.filled(events.length, false);
        for (int i = 0; i < events.length - 1; i++) {
          DateTime endTimeCurrent = DateTime.parse('${events[i]['event']['date']} ${events[i]['event']['end_hour']}');
          DateTime startTimeNext = DateTime.parse('${events[i + 1]['event']['date']} ${events[i + 1]['event']['start_hour']}');

          if (endTimeCurrent.isAfter(startTimeNext)) {
            isOverlapping[i] = true;
            isOverlapping[i + 1] = true;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Cards para cada evento utilizando CustomEventCard
            ...events.asMap().entries.map<Widget>((entry) {
              final index = entry.key;
              final eventData = entry.value;
              final event = eventData['event'];
              final classType = eventData['classType'];
              final subjectName = eventData['subjectName'];
              final bool isOverlap = isOverlapping[index];

              return ClassCards(
                subjectName: subjectName,
                classType: '$classType - ${getGroupLabel(classType[0])}', // Aquí se añade el tipo de clase
                event: event,
                isOverlap: isOverlap,
              );
            }),
          ],
        );
      },
    );
  }
}