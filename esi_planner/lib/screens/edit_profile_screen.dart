import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final String username;
  const EditProfileScreen({super.key, required this.username});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileService _profileService = EditProfileService();

  // Controladores para los campos de entrada
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar los datos del perfil actual
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Llamar a la API para obtener los datos del perfil del usuario
    final profileData = await _profileService.getProfileData(username: widget.username);

    if (profileData['success']) {
      // Cargar los datos en los controladores si la solicitud fue exitosa
      nameController.text = profileData['name'];
      surnameController.text = profileData['surname'];
      degreeController.text = profileData['degree'];
    } else {
      // Manejar el error (por ejemplo, mostrar un mensaje de error)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(profileData['message']),
      ));
    }
  }

  Future<void> _updateProfile() async {
    // Preparar los datos para actualizar el perfil
    Map<String, dynamic> updatedData = {
      'name': nameController.text,
      'surname': surnameController.text,
      'degree': degreeController.text,
    };

    // Llamar a la API para actualizar los datos
    final updateResult = await _profileService.updateProfileData(
      username: widget.username,
      updatedData: updatedData,
    );

    if (updateResult['success']) {
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Perfil actualizado con éxito'),
      ));
    } else {
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(updateResult['message']),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica tu perfil', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: surnameController,
              decoration: const InputDecoration(labelText: 'Apellido'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: degreeController,
              decoration: const InputDecoration(labelText: 'Grado'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile, // Llamar a la función para actualizar los datos
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
