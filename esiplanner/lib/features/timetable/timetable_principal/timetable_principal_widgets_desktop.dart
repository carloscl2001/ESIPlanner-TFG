import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'timetable_principal_logic.dart';
import '../timetable_week/timetable_week_screen.dart';

class WeekDaysHeaderDesktop extends StatelessWidget {
  final bool isDarkMode;
  final TimetablePrincipalLogic timetableLogic;

  const WeekDaysHeaderDesktop({super.key, required this.isDarkMode, required this.timetableLogic});

  @override
  Widget build(BuildContext context) {
    final accentColor = isDarkMode ? AppColors.amarillo : AppColors.blanco;
    final bgColor = isDarkMode ? AppColors.negro : AppColors.azulUCA;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.negro.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final dayNames = timetableLogic.weekFullDays;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text(
                      dayNames[index],
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class WeekSelectorDesktop extends StatelessWidget {
  final TimetablePrincipalLogic timetableLogic;
  final bool isDarkMode;

  const WeekSelectorDesktop({
    super.key,
    required this.timetableLogic,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final weeks = timetableLogic.getWeeksOfSemester();
    final currentWeekIndex = timetableLogic.getCurrentWeekIndex(weeks);

    return ListView.builder(
      key: const PageStorageKey('timetable'),
      shrinkWrap: false,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: weeks.length,
      itemBuilder: (context, index) {
        final weekDays = weeks[index];
        final startDate = weekDays.first;
        final isCurrentWeek = index == currentWeekIndex;

        return Column(
          children: [
            if (index == 0 || timetableLogic.isNewMonth(weekDays, weeks[index - 1]))
              _buildMonthHeader(startDate, isDarkMode),
            WeekRowDesktop(
              weekDays: weekDays,
              weekIndex: index,
              isDarkMode: isDarkMode,
              isCurrentWeek: isCurrentWeek,
              timetableLogic: timetableLogic,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMonthHeader(DateTime startDate, bool isDarkMode) {
    final bgColor = isDarkMode ? Colors.grey[900]! : AppColors.azulClaro3;
    
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                DateFormat('MMMM', 'es_ES').format(startDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blanco,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                DateFormat('y').format(startDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blanco,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekRowDesktop extends StatefulWidget {
  final List<DateTime> weekDays;
  final int weekIndex;
  final bool isDarkMode;
  final bool isCurrentWeek;
  final TimetablePrincipalLogic timetableLogic;

  const WeekRowDesktop({
    super.key,
    required this.weekDays,
    required this.weekIndex,
    required this.isDarkMode,
    required this.isCurrentWeek,
    required this.timetableLogic,
  });

  @override
  State<WeekRowDesktop> createState() => _WeekRowDesktopState();
}

class _WeekRowDesktopState extends State<WeekRowDesktop> {
  bool _isHovered = false;
  final double _normalHeight = 72;
  final double _hoverHeight = 86;

  void setHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.isDarkMode ? AppColors.amarillo : AppColors.azulUCA;
    final textColor = widget.isDarkMode ? AppColors.blanco : AppColors.negro;

    return AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  curve: Curves.easeInOut,
  margin: const EdgeInsets.symmetric(vertical: 6),
  height: _isHovered ? _hoverHeight : _normalHeight,
  decoration: BoxDecoration(
    color: widget.isDarkMode
        ? _isHovered 
            ? AppColors.gris1 // Color más claro al hacer hover en modo oscuro
            : AppColors.gris1_2 // Color normal en modo oscuro
        : _isHovered 
            ? AppColors.azulClaroUCA2 // Color más claro al hacer hover en modo oscuro
            : AppColors.blanco, // Color normal en modo oscuro
    borderRadius: BorderRadius.circular(10),
    border: widget.isCurrentWeek
        ? Border.all(color: accentColor, width: 2)
        : null,
    boxShadow: [
      BoxShadow(
        color: AppColors.negro.withValues(alpha: 0.1),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _navigateToWeekScreen(context),
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: MouseRegion(
        onEnter: (event) => setHover(true),
        onExit: (event) => setHover(false),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: List.generate(5, (index) {
              final day = widget.weekDays[index];
              final hasClass = widget.timetableLogic.dayHasClass(day);
              
              return Expanded(
                child: _buildDayCell(day, hasClass, textColor, accentColor),
              );
            }),
          ),
        ),
      ),
    ),
  ),
);
  }

  Widget _buildDayCell(DateTime day, bool hasClass, Color textColor, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('d').format(day),
          style: TextStyle(
            color: textColor,
            fontSize: _isHovered ? 30 : 28,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 8,
          child: hasClass
              ? Container(
                  width: 8,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _navigateToWeekScreen(BuildContext context) {
    final weekRange = widget.timetableLogic.weekRanges[widget.weekIndex];
    final allEvents = widget.timetableLogic.getFilteredEvents(weekRange);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetableWeekScreen(
          events: allEvents,
          selectedWeekIndex: widget.weekIndex,
          isDarkMode: widget.isDarkMode,
          weekStartDate: widget.weekDays.first,
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
    final textColor = isDarkMode ? AppColors.blanco70 : AppColors.negro54;
    
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