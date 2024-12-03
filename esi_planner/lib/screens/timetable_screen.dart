import 'package:flutter/material.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'This is the Timetable Screen!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
