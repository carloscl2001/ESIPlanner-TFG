import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/profile_service.dart';


// edit_password_logic.dart
class EditPasswordLogic {
  final BuildContext context;
  final TextEditingController newPasswordController = TextEditingController();
  String errorMessage = '';
  String successMessage = '';
  late ProfileService profileService;
  final VoidCallback onStateChanged; // Callback para notificar cambios

  EditPasswordLogic(this.context, {required this.onStateChanged}) {
    profileService = ProfileService();
  }

  Future<void> updatePassword() async {
    final String newPassword = newPasswordController.text;
    // ... validaciones previas ...

    final String? username = Provider.of<AuthProvider>(context, listen: false).username;
    if (username == null) {
      errorMessage = 'El nombre de usuario no está disponible';
      onStateChanged(); // Notifica a la UI que debe actualizarse
      return;
    }

    final response = await profileService.updatePassword(
      username: username,
      newPassword: newPassword,
      context: context,
    );

    if (response['success']) {
      successMessage = response['message'];
      newPasswordController.clear();
    } else {
      errorMessage = response['message'];
    }
    onStateChanged(); // Notifica a la UI que debe actualizarse
  }
}