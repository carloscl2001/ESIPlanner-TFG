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
      body: SingleChildScrollView( // Permite scroll en caso de desbordamiento
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 80), // Espaciado inicial
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
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            errorStyle: TextStyle(
                              fontSize: 14,
                              overflow: TextOverflow.clip, // Permite saltos de línea
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese un correo electrónico';
                            }
                            String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                            if (!RegExp(pattern).hasMatch(value)) {
                              return 'Por favor, ingrese un correo electrónico válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Usuario',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            errorStyle: TextStyle(
                              fontSize: 14,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese un usuario';
                            } else if (value.length < 4) {
                              return 'El usuario debe tener al menos 4 dígitos';
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            errorStyle: TextStyle(
                              fontSize: 14,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese una contraseña';
                            } else if (value.length < 8) {
                              return 'La contraseña debe tener al menos  8 \ncaracteres';
                            }
                            String pattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&_\-=+])[A-Za-z\d@$!%*?&_\-=+]{8,}$';
                            if (!RegExp(pattern).hasMatch(value)) {
                              return 'La contraseña debe incluir letras, números y \nal menos un carácter especial';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            errorStyle: TextStyle(
                              fontSize: 14,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese su nombre';
                            } else if (value.length < 3) {
                              return 'El nombre debe tener al menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: surnameController,
                          decoration: const InputDecoration(
                            labelText: 'Apellidos',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(12)),
                            ),
                            errorStyle: TextStyle(
                              fontSize: 14,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, ingrese sus apellidos';
                            } else if (value.length < 3) {
                              return 'Los apellidos deben tener al menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                            value: degreeController.text.isNotEmpty ? degreeController.text : null,
                            onChanged: (String? newValue) {
                                setState(() {
                                degreeController.text = newValue ?? '';
                                });
                            },
                            decoration: const InputDecoration(
                                labelText: 'Grado',
                                border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                            ),  
                            items: <String>['Ingeniería Aeroespacial',
                                            'Ingeniería Informática', 
                                            'Ingeniería en Diseñó industrial y desarrollo del producto',
                                            'Ingeniería Eléctrica'
                                            ]
                                .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                                );
                            }).toList(),
                        ),
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
