import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class AgendaScreen extends StatelessWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AuthProvider>(context).username ?? 'Usuario';

    return Scaffold(
      body: Center(
        child: Text(
          'Aquí está tu agenda, $username.',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
