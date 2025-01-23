import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../auth_provider.dart';

class EditPasswordProfileScreen extends StatefulWidget {
  const EditPasswordProfileScreen({super.key});

  @override
  State<EditPasswordProfileScreen> createState() =>
      _EditPasswordProfileScreenState();
}

class _EditPasswordProfileScreenState extends State<EditPasswordProfileScreen> {
  late ProfileService profileService;
  String errorMessage = '';
  String successMessage = '';
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
  }

  Future<void> _updatePassword() async {

    bool isValidPassword(String password) {
      final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$');
      return passwordRegex.hasMatch(password);
    }

    final String newPassword = _newPasswordController.text;

    if (newPassword.isEmpty) {
      setState(() {
        errorMessage = 'Por favor, ingrese una nueva contraseña';
        successMessage = '';
      });
      return;
    }else if(newPassword.length < 8){
      setState(() {
        errorMessage = 'La contraseña debe tener al menos 8 caracteres';
        successMessage = '';
      });
      return;
    }else if(!isValidPassword(newPassword)){
      setState(() {
        errorMessage = 'La contraseña debe contner letras y números';
        successMessage = '';
      });
      return;
    }

    setState(() {
      errorMessage = '';
      successMessage = '';
    });

    final String? username =
        Provider.of<AuthProvider>(context, listen: false).username;

    if (username != null) {
      final response = await profileService.updatePassword(
        username: username,
        newPassword: newPassword,
        context: context,
      );

      setState(() {
        if (response['success']) {
          successMessage = response['message'];
          // Vaciar el input de la nueva contraseña al recibir el éxito
          _newPasswordController.clear();
        } else {
          errorMessage = response['message'];
        }
      });
    } else {
      setState(() {
        errorMessage = 'El nombre de usuario no está disponible';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar tu contraseña', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Text(
                    'Introduzca su nueva contraseña',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updatePassword,
                    child: const Text('Actualizar contraseña'),
                  ),
                  // Los mensajes de error y éxito aparecerán aquí debajo
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        successMessage,
                        style: const TextStyle(color: Color.fromRGBO(0, 89, 255, 1.0), fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
