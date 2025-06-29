import 'package:esiplanner/features/my_week/event_card_my_week_desktop.dart';
import 'package:esiplanner/providers/theme_provider.dart';
import 'package:esiplanner/shared/app_colors.dart';
import 'package:esiplanner/shared/subject_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SelectedDayRowDesktop extends StatelessWidget {
  final bool isDarkMode;
  final String selectedDay;
  final List<String> weekDaysFullName;
  final List<String> weekDaysShort;
  final String Function(int) getMonthName;

  const SelectedDayRowDesktop({
    super.key,
    required this.isDarkMode,
    required this.selectedDay,
    required this.weekDaysFullName,
    required this.weekDaysShort,
    required this.getMonthName,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final selectedDayLower = selectedDay.toLowerCase();
    final safeIndex = weekDaysShort
        .indexWhere(
          (day) => day.toLowerCase() == selectedDayLower.substring(0, 3),
        )
        .clamp(0, weekDaysFullName.length - 1);

    final selectedDate = DateTime.utc(
      now.year,
      now.month,
      now.day - (now.weekday - 1) + safeIndex,
    );

    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Container(
      padding: const EdgeInsets.only(left: 52, top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                selectedDate.day.toString(),
                style: TextStyle(
                  color: isDarkMode ? AppColors.blanco : AppColors.negro,
                  fontWeight: FontWeight.bold,
                  fontSize: 90,
                  height: 1,
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    weekDaysFullName[safeIndex],
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : AppColors.azulUCA,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${getMonthName(selectedDate.month)} ${selectedDate.year}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : AppColors.azulUCA,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                'Hoy',
                style: TextStyle(
                  color: isDarkMode ? AppColors.negro : AppColors.blanco,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 1.1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DayButtonRowDesktop extends StatefulWidget {
  final List<String> weekDays;
  final List<String> weekDates;
  final bool isDarkMode;
  final String selectedDay;
  final List<Map<String, dynamic>> Function(String?) getFilteredEvents;
  final List<Map<String, dynamic>> subjects;
  final Function(String) onDaySelected;

  const DayButtonRowDesktop({
    super.key,
    required this.weekDays,
    required this.weekDates,
    required this.isDarkMode,
    required this.selectedDay,
    required this.getFilteredEvents,
    required this.subjects,
    required this.onDaySelected,
  });

  @override
  State<DayButtonRowDesktop> createState() => _DayButtonRowDesktopState();
}

class _DayButtonRowDesktopState extends State<DayButtonRowDesktop> {
  late List<bool> _isHovered;

  @override
  void initState() {
    super.initState();
    _isHovered = List.filled(widget.weekDays.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            widget.weekDays.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;
              final date = widget.weekDates[index];
              final hasEvents = widget.getFilteredEvents(day).isNotEmpty;
              final isSelected = widget.selectedDay == day;
              final selectedColor =
                  widget.isDarkMode ? AppColors.amarillo : AppColors.azulUCA;

              return MouseRegion(
                onEnter: (_) => setState(() => _isHovered[index] = true),
                onExit: (_) => setState(() => _isHovered[index] = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform:
                      Matrix4.identity()..scale(_isHovered[index] ? 1.05 : 1.0),
                  child: GestureDetector(
                    onTap: () => widget.onDaySelected(day),
                    child: Container(
                      width: 80,
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? selectedColor : null,
                        gradient:
                            !isSelected
                                ? LinearGradient(
                                  colors:
                                      widget.isDarkMode
                                          ? [
                                            _isHovered[index]
                                                ? AppColors.gris1
                                                : AppColors.negro,
                                            AppColors.negro,
                                          ]
                                          : [
                                            _isHovered[index]
                                                ? AppColors.azulClaroUCA1
                                                : AppColors.blanco,
                                            AppColors.blanco,
                                          ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                                : null,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color:
                                !widget.isDarkMode
                                    ? AppColors.negro.withAlpha(
                                      _isHovered[index] ? 150 : 115,
                                    )
                                    : Colors.grey.withAlpha(
                                      _isHovered[index] ? 150 : 115,
                                    ),
                            blurRadius: _isHovered[index] ? 10.0 : 8.0,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? (widget.isDarkMode
                                          ? AppColors.negro
                                          : AppColors.blanco)
                                      : (widget.isDarkMode
                                          ? Colors.grey
                                          : AppColors.azulUCA),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            date,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? (widget.isDarkMode
                                          ? AppColors.negro
                                          : AppColors.blanco)
                                      : (widget.isDarkMode
                                          ? AppColors.blanco
                                          : AppColors.negro),
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                          if (hasEvents)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? (widget.isDarkMode
                                            ? AppColors.negro
                                            : AppColors.blanco)
                                        : (widget.isDarkMode
                                            ? AppColors.amarillo
                                            : AppColors.azulUCA),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

class EventListViewDesktopGoogle extends StatelessWidget {
  final PageController pageController;
  final List<String> weekDays;
  final List<Map<String, dynamic>> Function(String?) getFilteredEvents;
  final List<Map<String, dynamic>> subjects;
  final Map<String, List<Map<String, dynamic>>> Function(
    List<Map<String, dynamic>>,
  )
  groupEventsByDay;
  final String Function(String) getGroupLabel;
  final Function(int) onPageChanged;
  final double sizeTramo = 65;
  final bool isDesktop;
  final bool isDarkMode;

  const EventListViewDesktopGoogle({
    super.key,
    required this.pageController,
    required this.weekDays,
    required this.getFilteredEvents,
    required this.subjects,
    required this.groupEventsByDay,
    required this.getGroupLabel,
    required this.onPageChanged,
    required this.isDesktop,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    final subjectColors = SubjectColors(isDarkMode);
    final currentPage =
        pageController.hasClients ? pageController.page?.round() ?? 0 : 0;

    return SizedBox(
      child: Stack(
        children: [
          // Contenedor principal del calendario
          Positioned.fill(
            left: 56, // Espacio para la flecha izquierda
            right: 56, // Espacio para la flecha derecha
            top: 0,
            bottom: 30,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.negro : AppColors.blanco,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                  width: 3.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: onPageChanged,
                  physics: const PageScrollPhysics().applyTo(
                    const BouncingScrollPhysics(),
                  ),
                  itemCount: weekDays.length,
                  itemBuilder: (context, index) {
                    final day = weekDays[index];
                    final dayEvents = getFilteredEvents(day);

                    if (dayEvents.isEmpty) {
                      return _buildEmptyState(isDarkMode);
                    }

                    return _buildDayViewGoogleStyle(
                      dayEvents,
                      isDarkMode,
                      subjectColors,
                    );
                  },
                ),
              ),
            ),
          ),

          // Flecha izquierda - Solo visible si no es la primera página
          if (currentPage > 0)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavigationArrow(
                  context,
                  Icons.chevron_left,
                  () => pageController.previousPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),

          // Flecha derecha - Solo visible si no es la última página
          if (currentPage < weekDays.length - 1)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavigationArrow(
                  context,
                  Icons.chevron_right,
                  () => pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationArrow(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;

    return Material(
      shape: const CircleBorder(),
      color: Colors.transparent,
      child: IconButton(
        icon: Icon(icon, size: 30),
        color: isDarkMode ? AppColors.blanco : AppColors.negro,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.black54 : AppColors.blanco54,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 80,
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'No tienes clases',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Disfruta de tu tiempo libre!',
            style: TextStyle(
              fontSize: 24,
              color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayViewGoogleStyle(
    List<Map<String, dynamic>> events,
    bool isDarkMode,
    SubjectColors subjectColors,
  ) {
    final processedEvents =
        events.map((e) {
          final start = DateTime.parse(
            '${e['event']['date']} ${e['event']['start_hour']}',
          );
          final end = DateTime.parse(
            '${e['event']['date']} ${e['event']['end_hour']}',
          );
          return {
            'data': e,
            'start': start,
            'end': end,
            'subject': e['subjectName'],
          };
        }).toList();

    processedEvents.sort((a, b) => a['start'].compareTo(b['start']));

    if (processedEvents.isEmpty) {
      return const SizedBox.shrink();
    }

    final firstEventStart = processedEvents.first['start'];
    final lastEventEnd = processedEvents.last['end'];

    DateTime startTime = DateTime(
      firstEventStart.year,
      firstEventStart.month,
      firstEventStart.day,
      firstEventStart.hour,
      (firstEventStart.minute ~/ 30) * 30,
    ).subtract(const Duration(minutes: 30));

    DateTime endTime = DateTime(
      lastEventEnd.year,
      lastEventEnd.month,
      lastEventEnd.day,
      lastEventEnd.hour,
      ((lastEventEnd.minute + 29) ~/ 30) * 30,
    ).add(const Duration(minutes: 30));

    final totalHalfHours = endTime.difference(startTime).inMinutes ~/ 30;

    final List<List<Map<String, dynamic>>> lanes = [];
    final Map<Map<String, dynamic>, Map<String, int>> eventLanesPlacement = {};

    for (final event in processedEvents) {
      int bestLane = -1;
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
        eventLanesPlacement[event] = {
          'start': lanes.length - 1,
          'end': lanes.length,
        };
      }
    }

    int maxLanes = lanes.length;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 15, top: 0, bottom: 30),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: List.generate(totalHalfHours + 1, (index) {
                    final currentTime = startTime.add(
                      Duration(minutes: 30 * index),
                    );
                    return SizedBox(
                      height: sizeTramo,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Transform.translate(
                          offset: const Offset(-15, 31),
                          child: Text(
                            DateFormat('HH:mm').format(currentTime),
                            style: TextStyle(
                              color:
                                  isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.maxWidth;
                      return Stack(
                        children: [
                          Column(
                            children: List.generate(totalHalfHours + 1, (
                              index,
                            ) {
                              return Container(
                                height: sizeTramo,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          isDarkMode
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade300,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          ...processedEvents.map((event) {
                            final placement = eventLanesPlacement[event]!;
                            final laneStart = placement['start']!;
                            final laneEnd = placement['end']!;
                            final startOffset =
                                event['start'].difference(startTime).inMinutes;
                            final duration =
                                event['end']
                                    .difference(event['start'])
                                    .inMinutes;

                            final isOverlapping = lanes.any(
                              (lane) => lane.any(
                                (e) =>
                                    e != event &&
                                    event['start'].isBefore(e['end']) &&
                                    event['end'].isAfter(e['start']),
                              ),
                            );

                            final laneWidth =
                                availableWidth / (isOverlapping ? maxLanes : 1);
                            final leftPosition =
                                isOverlapping ? laneStart * laneWidth : 0;
                            final eventWidth =
                                isOverlapping
                                    ? (laneEnd - laneStart) * laneWidth
                                    : availableWidth;

                            return Positioned(
                              top: ((startOffset / 30) + 1) * sizeTramo + 2,
                              left: leftPosition + 2,
                              width: eventWidth - 4,
                              height: (duration / 30) * sizeTramo - 6,
                              child: EventCardMyWeekDesktop(
                                eventData: event['data'],
                                getGroupLabel: getGroupLabel,
                                subjectColor: subjectColors.getSubjectColor(
                                  event['subject'],
                                ),
                                isDarkMode: isDarkMode,
                                isDesktop: isDesktop,
                                isMyWeek: true,
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BuildEmptyCardDesktop extends StatelessWidget {
  const BuildEmptyCardDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.blanco70 : Colors.black54;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con libro tachado (representando "no asignaturas")
            Stack(
              children: [
                Icon(Icons.auto_stories_rounded, size: 120, color: textColor),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.question_mark_rounded,
                        size: 35,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Título y mensaje
            const SizedBox(height: 30),
            Text(
              'No has seleccionado niguna asignatura',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: textColor, height: 1.5),
                  children: [
                    const TextSpan(text: 'Puedes seleccionar tus asignaturas '),
                    const TextSpan(text: 'en la sección de '),
                    TextSpan(
                      text: 'Perfil',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                      ),
                    ),
                    const TextSpan(text: ' o '),
                    TextSpan(
                      text: 'desde aquí',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Botón principal
            FilledButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, '/selectionSubjects');
                Navigator.pushNamed(context, '/home');
              },
              icon: const Icon(Icons.touch_app_rounded),
              label: const Text(
                'Seleccionar asignaturas ahora',
                style: TextStyle(
                  fontSize: 18, // Ajusta este valor según necesites
                ),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 25,
                ),
                backgroundColor:
                    isDarkMode
                        ? AppColors.amarillo.withValues(alpha: 0.8)
                        : AppColors.azulUCA,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationArrows extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool showPrevious;
  final bool showNext;
  final double iconSize;
  final EdgeInsets padding;

  const NavigationArrows({
    super.key,
    required this.isDarkMode,
    required this.onPrevious,
    required this.onNext,
    required this.showPrevious,
    required this.showNext,
    this.iconSize = 40,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    final arrowColor = isDarkMode ? AppColors.blanco : AppColors.azulUCA;

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showPrevious)
            IconButton(
              icon: Icon(Icons.chevron_left, size: iconSize, color: arrowColor),
              onPressed: onPrevious,
            )
          else
            SizedBox(width: iconSize),
          if (showNext)
            IconButton(
              icon: Icon(
                Icons.chevron_right,
                size: iconSize,
                color: arrowColor,
              ),
              onPressed: onNext,
            )
          else
            SizedBox(width: iconSize),
        ],
      ),
    );
  }
}
