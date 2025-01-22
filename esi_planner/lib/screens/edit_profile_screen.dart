import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controladores para cada campo
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController degreeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Aquí puedes cargar los datos existentes del perfil (si es necesario).
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifica tu perfil',  style: TextStyle(color: Colors.white), ),
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
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: degreeController,
              decoration: const InputDecoration(labelText: 'Grado'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes hacer la lógica para actualizar el perfil
                // Por ejemplo, enviar los datos a la API
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
