import 'package:esiplanner/shared/app_colors.dart';
import 'package:esiplanner/features/timetable/timetable_week/event_card_timetable_week_mobile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timetable_week_logic.dart';
import '../../../shared/widgets/class_cards.dart';
import '../../../shared/subject_colors.dart';

class WeekHeaderMobile extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const WeekHeaderMobile({super.key, required this.logic, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final headerInfo = logic.getWeekHeaderInfo();
    final showTwoMonths = headerInfo['startMonth'] != headerInfo['endMonth'];
    final showTwoYears = headerInfo['startYear'] != headerInfo['endYear'];

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              showTwoMonths 
                  ? '${headerInfo['startMonth']} - ${headerInfo['endMonth']}'
                  : headerInfo['startMonth']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.negro : AppColors.blanco,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              showTwoYears
                  ? '${headerInfo['startYear']} - ${headerInfo['endYear']}'
                  : headerInfo['startYear']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.negro : AppColors.blanco,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekHeaderMobileGoogle extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const WeekHeaderMobileGoogle({super.key, required this.logic, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final headerInfo = logic.getWeekHeaderInfo();
    final showTwoMonths = headerInfo['startMonth'] != headerInfo['endMonth'];
    final showTwoYears = headerInfo['startYear'] != headerInfo['endYear'];

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.gris1 : AppColors.azulClaro3,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              showTwoMonths 
                  ? '${headerInfo['startMonth']} - ${headerInfo['endMonth']}'
                  : headerInfo['startMonth']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.blanco : AppColors.blanco,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.gris1 : AppColors.azulClaro3,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            child: Text(
              showTwoYears
                  ? '${headerInfo['startYear']} - ${headerInfo['endYear']}'
                  : headerInfo['startYear']!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.blanco : AppColors.blanco,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekDaysHeaderMobile extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;

  const WeekDaysHeaderMobile({super.key, required this.logic, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final weekDays = logic.getWeekDays();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.negro : AppColors.blanco,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isDarkMode ? Colors.transparent : AppColors.azulUCA,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.grey.withValues(alpha: 0.45) 
                : AppColors.negro.withValues(alpha: 0.45),
            blurRadius: isDarkMode ? 0.0 : 6.0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final day = weekDays[index];
          return Column(
            children: [
              Text(
                (logic.weekDays[index]),
                style: TextStyle(
                  color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('d', 'es_ES').format(day),
                style: TextStyle(
                  color: isDarkMode ? AppColors.blanco : AppColors.negro,
                  fontSize: 20,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class EventListMobile extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;
  final bool isDesktop;

  const EventListMobile({super.key, required this.logic, required this.isDarkMode, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final groupedByDate = logic.groupEventsByDate();
    final sortedDates = groupedByDate.keys.toList()..sort();

    if (groupedByDate.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final events = groupedByDate[date]!..sort(logic.sortEventsByTime);
        final isOverlapping = logic.calculateOverlappingEvents(events);

        return Padding(
          padding: const EdgeInsets.only(top: 10.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  logic.formatDateToFullDate(DateTime.parse(date)),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              ...events.asMap().entries.map((entry) {
                final index = entry.key;
                final eventData = entry.value;
                final event = eventData['event'];
                final classType = eventData['classType'];
                final subjectName = eventData['subjectName'];

                return ClassCards(
                  subjectName: subjectName,
                  classType: '$classType - ${logic.getGroupLabel(classType[0])}',
                  event: event,
                  isOverlap: isOverlapping[index],
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 60,
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No tienes clases',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Disfruta de tu tiempo libre!',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}


class ViewToggleFab extends StatelessWidget {
  final bool isDarkMode;
  final bool showGoogleView;
  final VoidCallback onPressed;

  const ViewToggleFab({
    super.key,
    required this.isDarkMode,
    required this.showGoogleView,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: showGoogleView ? 'Ver formato lista' : 'Ver vista calendario',
      backgroundColor: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
      child: Icon(
        Icons.autorenew_rounded,
        color: isDarkMode ? AppColors.negro : AppColors.blanco,
      ),
    );
  }
}

class WeeklyViewMobileGoogle extends StatelessWidget {
  final TimetableWeekLogic logic;
  final bool isDarkMode;
  late final TimeOfDay startHour;
  late final TimeOfDay endHour;
  final bool isDesktop;

  WeeklyViewMobileGoogle({
    super.key,
    required this.logic,
    required this.isDarkMode,
    required this.isDesktop,
  }) {
    // Calcular horas de inicio y fin basadas en los eventos de la semana
    final timeRange = _calculateTimeRange();
    startHour = timeRange['start'] ?? const TimeOfDay(hour: 8, minute: 0);
    endHour = timeRange['end'] ?? const TimeOfDay(hour: 22, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcula dimensiones basadas en las constraints
        final timeColumnWidth = 40.0;
        final hourSlotHeight = 40.0;
        final tamanoarespetar = 20.0;
        final dayColumnWidth = (constraints.maxWidth - timeColumnWidth - tamanoarespetar) / 5;

        final weekDays = logic.weekDays;
        final weekDates = logic.getWeekDays();
        final eventsByDate = logic.groupEventsByDate();
        final subjectColors = SubjectColors(isDarkMode);

        return Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900.withAlpha(153) : AppColors.blanco,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? AppColors.negro : Colors.grey.shade400,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header con los días de la semana
                _buildDaysHeaderMobile(weekDays, weekDates, timeColumnWidth, dayColumnWidth),
                // Contenido principal con horas y eventos
                Expanded(
                  child: _buildTimeAndEventsContentMobile(
                    weekDays: weekDays,
                    weekDates: weekDates,
                    eventsByDate: eventsByDate,
                    subjectColors: subjectColors,
                    timeColumnWidth: timeColumnWidth,
                    dayColumnWidth: dayColumnWidth,
                    hourSlotHeight: hourSlotHeight,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDaysHeaderMobile(
    List<String> weekDays,
    List<DateTime> weekDates,
    double timeColumnWidth,
    double dayColumnWidth,
  ) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.negro : AppColors.azulUCA,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: timeColumnWidth,
            child: Center(
              child: Text(
                'Hora',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.blanco,
                ),
              ),
            ),
          ),
          ...weekDays.asMap().entries.map((entry) {
            final index = entry.key;
            final day = entry.value;
            final isToday = _isToday(weekDates[index]);
            return Container(
              width: dayColumnWidth,
              decoration: BoxDecoration(
                border: Border(
                  right: index == weekDays.length - 1 // Solo para el último elemento
                      ? BorderSide.none // Elimina el borde derecho del último elemento
                      : BorderSide(
                          color: isDarkMode ? Colors.grey.shade800 : AppColors.azulUCA,
                          width: 1,
                        ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day, // Now using the full day name
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16, // Slightly smaller font to accommodate longer names
                      color: AppColors.blanco,
                      decoration: isToday ? TextDecoration.underline : TextDecoration.none,
                      decorationColor: isDarkMode ? AppColors.amarillo : AppColors.blanco,
                    ),
                  ),
                  Text(
                    DateFormat('d').format(weekDates[index]),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blanco.withAlpha(150),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeAndEventsContentMobile({
    required List<String> weekDays,
    required List<DateTime> weekDates,
    required Map<String, List<Map<String, dynamic>>> eventsByDate,
    required SubjectColors subjectColors,
    required double timeColumnWidth,
    required double dayColumnWidth,
    required double hourSlotHeight,
  }) {
    final totalSlots = _calculateTotalTimeSlots();
    
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna de horas
          _buildTimeColumnMobile(totalSlots, timeColumnWidth, hourSlotHeight),
          // Columnas de días
          ...List.generate(weekDays.length, (index) {
            final dateKey = DateFormat('yyyy-MM-dd').format(weekDates[index]);
            final dayEvents = eventsByDate[dateKey] ?? [];
            dayEvents.sort(logic.sortEventsByTime);
            
            return _buildDayColumnMobile(
              events: dayEvents,
              subjectColors: subjectColors,
              totalSlots: totalSlots,
              dayColumnWidth: dayColumnWidth,
              hourSlotHeight: hourSlotHeight,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeColumnMobile(int totalSlots, double timeColumnWidth, double hourSlotHeight) {
    return Container(
      width: timeColumnWidth,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      ),
      child: Column(
        children: List.generate(totalSlots, (index) {
          final currentTime = _getTimeForSlot(index);
          return SizedBox(
            height: hourSlotHeight,
            child: Transform.translate(
              offset: Offset(0, -10.0), // Mueve el texto 2 píxeles hacia arriba
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  index == 0 ? "" : DateFormat('HH:mm').format(currentTime),
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDayColumnMobile({
    required List<Map<String, dynamic>> events,
    required SubjectColors subjectColors,
    required int totalSlots,
    required double dayColumnWidth,
    required double hourSlotHeight,
  }) {
    final overlappingInfo = logic.calculateOverlappingEvents(events);

    return Container(
      width: dayColumnWidth,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Líneas horizontales - ahora con Container separado para mejor control
          Column(
            children: List.generate(totalSlots, (index) {
              return Container(
                height: hourSlotHeight,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                ),
              );
            }),
          ),
          // Eventos
          ..._buildEventsForDayMobile(
            events: events,
            overlappingInfo: overlappingInfo,
            subjectColors: subjectColors,
            dayColumnWidth: dayColumnWidth,
            hourSlotHeight: hourSlotHeight,
          ),
        ],
      ),
    );
  }
 

  List<Widget> _buildEventsForDayMobile({
    required List<Map<String, dynamic>> events,
    required List<bool> overlappingInfo,
    required SubjectColors subjectColors,
    required double dayColumnWidth,
    required double hourSlotHeight,
  }) {
    final List<Widget> widgets = [];
    
    // Procesamos los eventos para determinar solapamientos
    final processedEvents = events.map((eventData) {
      final event = eventData['event'];
      final startTime = DateTime.parse('${event['date']} ${event['start_hour']}');
      final endTime = DateTime.parse('${event['date']} ${event['end_hour']}');
      return {
        'data': eventData,
        'start': startTime,
        'end': endTime,
        'subject': eventData['subjectName'],
      };
    }).toList();

    // Ordenamos los eventos por hora de inicio
    processedEvents.sort((a, b) => a['start'].compareTo(b['start']));

    // Creamos carriles para manejar los eventos solapados
    final List<List<Map<String, dynamic>>> lanes = [];
    final Map<Map<String, dynamic>, Map<String, int>> eventLanesPlacement = {};

    for (final event in processedEvents) {
      int bestLane = -1;
      // Buscamos el primer carril disponible
      for (int i = 0; i < lanes.length; i++) {
        bool canPlace = true;
        for (final existingEvent in lanes[i]) {
          if (event['start'].isBefore(existingEvent['end']) && 
              event['end'].isAfter(existingEvent['start'])) {
            canPlace = false;
            break;
          }
        }
        if (canPlace) {
          bestLane = i;
          break;
        }
      }

      if (bestLane != -1) {
        lanes[bestLane].add(event);
        eventLanesPlacement[event] = {'start': bestLane, 'end': bestLane + 1};
      } else {
        lanes.add([event]);
        eventLanesPlacement[event] = {'start': lanes.length - 1, 'end': lanes.length};
      }
    }

    final int maxLanes = lanes.isEmpty ? 1 : lanes.length;

    // Construimos los widgets de los eventos
    for (final event in processedEvents) {
      final placement = eventLanesPlacement[event]!;
      final laneStart = placement['start']!;
      final laneEnd = placement['end']!;
      final eventData = event['data'];
      final subjectName = event['subject'];
      final subjectColor = subjectColors.getSubjectColor(subjectName);
      
      final topPosition = _calculateEventTopPosition(event['start'], hourSlotHeight);
      final height = _calculateEventHeight(event['start'], event['end'], hourSlotHeight);
      
      final isOverlapping = lanes.any((lane) => 
          lane.any((e) => 
              e != event && 
              event['start'].isBefore(e['end']) && 
              event['end'].isAfter(e['start']))
      );

      final laneWidth = dayColumnWidth / (isOverlapping ? maxLanes : 1);
      final leftPosition = isOverlapping ? laneStart * laneWidth : 0;
      final eventWidth = isOverlapping ? (laneEnd - laneStart) * laneWidth : dayColumnWidth;

      widgets.add(
        Positioned(
          top: topPosition + 2,
          left: leftPosition + 2,
          width: eventWidth - 4,
          height: height - 4,
          child: EventCardTimetableWeekMobile(
            eventData: eventData,
            getGroupLabel: logic.getGroupLabel,
            subjectColor: subjectColor,
            isDarkMode: isDarkMode,
          ),
        ),
      );
    }
    
    return widgets;
  }

  Map<String, TimeOfDay> _calculateTimeRange() {
    TimeOfDay? earliestStart;
    TimeOfDay? latestEnd;
    final eventsByDate = logic.groupEventsByDate();

    // Buscar en todos los eventos de la semana
    for (final dateEvents in eventsByDate.values) {
      for (final eventData in dateEvents) {
        final event = eventData['event'];
        final startParts = event['start_hour'].split(':');
        final endParts = event['end_hour'].split(':');
        
        final start = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
        final end = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));

        // Ajustar para que empiece 30 min antes y termine 30 min después
        final adjustedStart = _subtract30Minutes(start);
        final adjustedEnd = _add30Minutes(end);

        if (earliestStart == null || adjustedStart.hour < earliestStart.hour || 
            (adjustedStart.hour == earliestStart.hour && adjustedStart.minute < earliestStart.minute)) {
          earliestStart = adjustedStart;
        }

        if (latestEnd == null || adjustedEnd.hour > latestEnd.hour || 
            (adjustedEnd.hour == latestEnd.hour && adjustedEnd.minute > latestEnd.minute)) {
          latestEnd = adjustedEnd;
        }
      }
    }

    // Si no hay eventos, usar valores por defecto
    return {
      'start': earliestStart ?? TimeOfDay(hour: 8, minute: 0),
      'end': latestEnd ?? TimeOfDay(hour: 20, minute: 0),
    };
  }

  TimeOfDay _subtract30Minutes(TimeOfDay time) {
    int totalMinutes = time.hour * 60 + time.minute - 30;
    if (totalMinutes < 0) totalMinutes += 1440; // Ajustar si pasa a día anterior
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  TimeOfDay _add30Minutes(TimeOfDay time) {
    int totalMinutes = time.hour * 60 + time.minute + 30;
    if (totalMinutes >= 1440) totalMinutes -= 1440; // Ajustar si pasa a día siguiente
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  // Métodos auxiliares
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  int _calculateTotalTimeSlots() {
    final startMinutes = startHour.hour * 60 + startHour.minute;
    final endMinutes = endHour.hour * 60 + endHour.minute;
    return (endMinutes - startMinutes) ~/ 30;
  }

  DateTime _getTimeForSlot(int slotIndex) {
    final minutes = startHour.hour * 60 + startHour.minute + (slotIndex * 30);
    return DateTime(2023, 1, 1, minutes ~/ 60, minutes % 60);
  }

  double _calculateEventTopPosition(DateTime eventStart, double hourSlotHeight) {
    final startMinutes = startHour.hour * 60 + startHour.minute;
    final eventMinutes = eventStart.hour * 60 + eventStart.minute;
    final slotIndex = (eventMinutes - startMinutes) ~/ 30;
    return slotIndex * hourSlotHeight;
  }

  double _calculateEventHeight(DateTime eventStart, DateTime eventEnd, double hourSlotHeight) {
    final durationMinutes = eventEnd.difference(eventStart).inMinutes;
    return (durationMinutes / 30) * hourSlotHeight;
  }
}