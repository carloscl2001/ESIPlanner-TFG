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
  bool isLoading = false;
  String errorMessage = '';
  String successMessage = '';
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    profileService = ProfileService();
  }

  Future<void> _updatePassword() async {
    final String newPassword = _newPasswordController.text;

    if (newPassword.isEmpty) {
      setState(() {
        errorMessage = 'La contraseña no puede estar vacía';
        successMessage = '';
      });
      return;
    }

    setState(() {
      isLoading = true;
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
        isLoading = false;
        if (response['success']) {
          successMessage = response['message'];
        } else {
          errorMessage = response['message'];
        }
      });
    } else {
      setState(() {
        isLoading = false;
        errorMessage = 'El nombre de usuario no está disponible';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar contraseña', style: TextStyle(color: Colors.white)),
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
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva Contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isLoading) 
                    const Center(child: CircularProgressIndicator()),  // Aquí solo aparece el CircularProgressIndicator cuando isLoading es true
                  if (!isLoading) 
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
