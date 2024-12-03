import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;

  void login(String username) {
    _isAuthenticated = true;
    _username = username;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _username = null;
    notifyListeners();
  }
}