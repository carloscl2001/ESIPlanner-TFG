import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = "";

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Detenemos si el formulario no es válido
    }

    final String username = usernameController.text;
    final String password = passwordController.text;

    final authService = AuthService();
    final result = await authService.login(username: username, password: password);

    if (result['success']) {
      // Autenticación exitosa
      context.read<AuthProvider>().authenticate();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Mostrar mensaje de error específico
      setState(() {
        errorMessage = result['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingrese su contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: login,
                child: const Text('Iniciar Sesión'),
              ),
              const SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: const Text("¿No tienes una cuenta? Regístrate aquí"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
