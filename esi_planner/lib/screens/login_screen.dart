import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
  bool isLoading = false;

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String username = usernameController.text;
    final String password = passwordController.text;

    final authService = AuthService();
    final result = await authService.login(username: username, password: password);

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      final String? token = result['data']['access_token']; // Accediendo al token correctamente
      if (token != null) {
        context.read<AuthProvider>().login(username, token);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          errorMessage = 'No se recibió un token válido.';
        });
      }
    } else {
      setState(() {
        errorMessage = result['message']; // Mostrar el mensaje de error si el login falla
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Bordes más redondeados
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.indigo.shade50, Colors.white], // Degradado suave
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.0), // Coincide con el radio de la tarjeta
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 20),
                          Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade900,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Campo de usuario
                          TextFormField(
                            controller: usernameController,
                            decoration: InputDecoration(
                              labelText: 'Usuario',
                              labelStyle: TextStyle(
                                color: Colors.indigo.shade700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
                                borderSide: BorderSide(color: Colors.indigo.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Colors.indigo.shade700, width: 3),
                              ),
                              prefixIcon: Icon(
                                Icons.person, // Icono para el campo de usuario
                                color: Colors.indigo.shade700,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su usuario';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // Campo de contraseña
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              labelStyle: TextStyle(
                                color: Colors.indigo.shade700,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Colors.indigo.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Colors.indigo.shade700, width: 3),
                              ),
                              prefixIcon: Icon(
                                Icons.lock, // Icono para el campo de contraseña
                                color: Colors.indigo.shade700,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su contraseña';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          // Botón de inicio de sesión
                          ElevatedButton(
                            onPressed: isLoading ? null : login, // Deshabilita el botón si está cargando
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade700, // Color de fondo del botón
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0), // Bordes redondeados
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          if (errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.indigo.shade700, // Color del texto
                ),
                child: const Text(
                  "¿No tienes una cuenta? Regístrate aquí",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}