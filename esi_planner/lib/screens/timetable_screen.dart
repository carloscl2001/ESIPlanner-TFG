import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AuthProvider>(context).username ?? 'Usuario';

    return Scaffold(
      body: Center(
        child: Text(
          'Aquí está tu horario, $username.',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
