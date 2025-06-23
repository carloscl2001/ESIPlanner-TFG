import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'timetable_week_logic.dart';
import 'timetable_week_widgets_desktop.dart';
import 'timetable_week_widgets_mobile.dart';

class TimetableWeekScreen extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final int selectedWeekIndex;
  final bool isDarkMode;
  final DateTime weekStartDate;

  const TimetableWeekScreen({
    super.key,
    required this.events,
    required this.selectedWeekIndex,
    required this.isDarkMode,
    required this.weekStartDate,
  });

  @override
  State<TimetableWeekScreen> createState() => _TimetableWeekScreenState();
}

class _TimetableWeekScreenState extends State<TimetableWeekScreen> {
  bool _showGoogleView = false;

  void _toggleView() {
    setState(() {
      _showGoogleView = !_showGoogleView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final logic = TimetableWeekLogic(events: widget.events, weekStartDate: widget.weekStartDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis clases de la semana'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 10,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode ? AppColors.negro : AppColors.azulUCA,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1024;

          return Column(
            children: [
              if (isDesktop) ...[
                WeekHeaderDesktop(logic: logic, isDarkMode: widget.isDarkMode),
                Expanded(
                  child: WeeklyViewDesktopGoogle(logic: logic, isDarkMode: widget.isDarkMode, isDesktop: isDesktop),
                ),
              ] else ...[
                Expanded(
                  child: _showGoogleView
                      ? Column(
                          children: [
                            WeekHeaderMobile(logic: logic, isDarkMode: widget.isDarkMode),
                            WeekDaysHeaderMobile(logic: logic, isDarkMode: widget.isDarkMode),
                            Expanded(
                              child: EventListMobile(
                                logic: logic,
                                isDarkMode: widget.isDarkMode,
                                isDesktop: isDesktop,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            WeekHeaderMobileGoogle(logic: logic, isDarkMode: widget.isDarkMode),
                            Expanded(
                              child: WeeklyViewMobileGoogle(
                                logic: logic,
                                isDarkMode: widget.isDarkMode,
                                isDesktop: isDesktop,
                              ),
                            ),
                          ],
                        )
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 1024;
          return isDesktop 
              ? const SizedBox.shrink() // Widget vacío en desktop
              : ViewToggleFab(
                  isDarkMode: widget.isDarkMode,
                  showGoogleView: _showGoogleView,
                  onPressed: _toggleView,
                );
        },
      ),
    );
  }
}

