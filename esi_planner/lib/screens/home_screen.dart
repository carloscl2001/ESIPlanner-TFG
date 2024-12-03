import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<AuthProvider>(context).username ?? 'Usuario';

    return Scaffold(
      body: Center(
        child: Text(
          'Bienvenido, $username! Este es tu Home.',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
