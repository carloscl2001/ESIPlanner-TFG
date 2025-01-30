import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../services/subject_service.dart';
import '../auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late ProfileService profileService;
  late SubjectService subjectService;

  bool isLoading = true;
  List<Map<String, dynamic>> subjects = [];
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
    subjectService = SubjectService();
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
          filteredClasses.forEach((classData) {
            classData['events'].sort((a, b) {
              DateTime dateA = DateTime.parse(a['date']);
              DateTime dateB = DateTime.parse(b['date']);
              return dateA.compareTo(dateB);
            });
          });

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

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
        title: const Text(
          'Tus clases esta semana',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo, // Color de la barra de navegación
      ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                if (errorMessage.isNotEmpty) ...[
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                ],
                Expanded(
                  child: _buildEventList(),
                ),
              ],
            ),
          ),
  );
}

Widget _buildEventList() {
  // Recopilar todos los eventos de todas las asignaturas
  List<Map<String, dynamic>> allEvents = [];
  for (var subject in subjects) {
    for (var classData in subject['classes']) {
      for (var event in classData['events']) {
        allEvents.add({
          'subjectName': subject['name'] ?? 'No Name',
          'classType': classData['type'] ?? 'No disponible',
          'event': event,
        });
      }
    }
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Título con la fecha
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Fecha: $date',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
          ),
          // Cards para cada evento
          ...events.map<Widget>((eventData) {
            final event = eventData['event'];
            final classType = eventData['classType'];
            final subjectName = eventData['subjectName'];

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0), // Bordes más redondeados
              ),
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade50, Colors.white], // Degradado suave
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.0), // Coincide con el radio de la tarjeta
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre de la asignatura dentro de la tarjeta
                      Text(
                        subjectName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tipo de clase con icono
                      Row(
                        children: [
                          Icon(
                            Icons.school, // Icono para el tipo de clase
                            size: 16,
                            color: Colors.indigo.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tipo de clase: $classType',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Hora del evento con icono
                      Row(
                        children: [
                          Icon(
                            Icons.access_time, // Icono para la hora
                            size: 16,
                            color: Colors.indigo.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${event['start_hour']} - ${event['end_hour']}',
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Ubicación del evento con icono
                      Row(
                        children: [
                          Icon(
                            Icons.location_on, // Icono para la ubicación
                            size: 16,
                            color: Colors.indigo.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${event['location']}',
                            style: TextStyle(
                              color: Colors.indigo.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      );
    },
  );
}
}
