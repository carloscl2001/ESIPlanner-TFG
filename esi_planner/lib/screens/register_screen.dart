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
  List<String> degrees = []; // Lista para almacenar los grados
  String? selectedDegree; // Variable para el grado seleccionado

  @override
  void initState() {
    super.initState();
    _loadDegrees(); // Cargar grados al iniciar la pantalla
  }

  // Método para cargar los grados desde la API
  Future<void> _loadDegrees() async {
    try {
      final authService = AuthService();
      final degreeList = await authService.getDegrees();
      setState(() {
        degrees = degreeList;
        selectedDegree = degrees.isNotEmpty ? degrees[0] : null; // Establece el primer grado como seleccionado si hay alguno
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar los grados';
      });
    }
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authService = AuthService();
    final result = await authService.register(
      email: emailController.text,
      username: usernameController.text,
      password: passwordController.text,
      name: nameController.text,
      surname: surnameController.text,
      degree: selectedDegree ?? '', // Usar el grado seleccionado
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
      backgroundColor: Colors.grey[200],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 80),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 20),
                        const Text(
                          'Registrarse',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Campo email
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese un email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Campo nombre de usuario
                        TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de usuario',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese un nombre de usuario';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Campo contraseña
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese una contraseña';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Campo nombre
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Campo apellido
                        TextFormField(
                          controller: surnameController,
                          decoration: const InputDecoration(
                            labelText: 'Apellido',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese su apellido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // DropdownButtonFormField para seleccionar el grado
                        const SizedBox(height: 20),
                        if (degrees.isNotEmpty) ...[
                          DropdownButtonFormField<String>(
                            value: selectedDegree,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedDegree = newValue;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Grado',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                            ),
                            items: degrees
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ] else ...[
                          const CircularProgressIndicator(), // Cargando si los grados están siendo obtenidos
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: register,
                          child: const Text('Registrarse'),
                        ),
                        if (errorMessage.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                            textAlign: TextAlign.center,
                            softWrap: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  "¿Ya tienes una cuenta? Inicia sesión aquí",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
