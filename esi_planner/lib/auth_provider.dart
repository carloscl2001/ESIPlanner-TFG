import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  // Método para autenticar al usuario
  void authenticate() {
    _isAuthenticated = true;
    notifyListeners();
  }

  // Método para hacer logout
  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
