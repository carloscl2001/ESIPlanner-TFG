import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();

  String errorMessage = "";

  Future<void> register() async {
    if(!_formKey.currentState!.validate()){
      return;
    }

    final authService = AuthService();
    final result = await authService.register(
      email: emailController.text,
      username: usernameController.text,
      password: passwordController.text,
      name: nameController.text,
      surname: surnameController.text,
      degree: degreeController.text,
    );

    if (result['success']) {
      context.read<AuthProvider>().authenticate();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        errorMessage = result['message'];
      });
    }
  }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200], // Fondo gris claro
        body: SingleChildScrollView( // Activa el scroll
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
            key: _formKey, // Asociamos el formulario con la clave global
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                const SizedBox(height: 40), // Añade un poco de espacio arriba
                TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)), // Bordes más redondeados
                    ),
                    ),
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese su email';
                    }
                    return null; // Validación exitosa
                    },
                ),
                const SizedBox(height: 20),
                TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)), // Bordes más redondeados
                    ),
                    ),
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese un usuario';
                    }
                    return null; // Validación exitosa
                    },
                ),
                const SizedBox(height: 20),
                TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                    labelText: 'Constraseña',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)), // Bordes más redondeados
                    ),
                    ),
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese una contraseña';
                    }
                    return null; // Validación exitosa
                    },
                ),
                const SizedBox(height: 20),
                TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)), // Bordes más redondeados
                        ),
                    ),
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese su nombre';
                    }
                    return null; // Validación exitosa
                    },
                ),
                const SizedBox(height: 20),
                TextFormField(
                    controller: surnameController,
                    decoration: const InputDecoration(
                        labelText: 'Apellidos',
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)), // Bordes más redondeados
                        ),
                    ),
                    validator: (value) {
                    if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese sus apellidos';
                    }
                    return null; // Validación exitosa
                    },
                ),
                const SizedBox(height: 20),
                TextField(
                    controller: degreeController,
                    decoration: const InputDecoration(
                        labelText: 'Grado',
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)), // Bordes más redondeados
                        ),
                    ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[850], // Usamos azul 850
                    minimumSize: const Size(double.infinity, 50), // Ancho igual al de los campos de texto
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)), // Bordes más redondeados
                    ),
                    ),
                    child: const Text('Registrarse'),
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
                    Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text("¿Ya tienes una cuenta? Inicia sesión aquí"),
                ),
                ],
            ),
            ),
        ),
        ),
    );
    }
}