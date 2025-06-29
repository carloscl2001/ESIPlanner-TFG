import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;
  String? _token;
  int _unreadNotificationsCount = 0;
  DateTime? _lastNotificationsVisit;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get token => _token;
  int get getUnreadNotificationsCount => _unreadNotificationsCount;
  DateTime? get lastNotificationsVisit => _lastNotificationsVisit;

  Future<void> loadAuthState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _username = prefs.getString('username');
    _token = prefs.getString('token');
    _unreadNotificationsCount = prefs.getInt('unreadNotificationsCount') ?? 0;
    
    final lastVisitString = prefs.getString('lastNotificationsVisit');
    _lastNotificationsVisit = lastVisitString != null 
        ? DateTime.parse(lastVisitString) 
        : null;
    
    notifyListeners();
  }

  Future<void> login(String username, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = true;
    _username = username;
    _token = token;

    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('username', username);
    await prefs.setString('token', token);
    notifyListeners();
  }

  Future<void> register(String username, String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = true;
    _username = username;
    _token = token;

    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('username', username);
    await prefs.setString('token', token);
    await prefs.setInt('unreadNotificationsCount', 0);
    _unreadNotificationsCount = 0;
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = false;
    _username = null;
    _token = null;
    _unreadNotificationsCount = 0;
    _lastNotificationsVisit = null;

    await prefs.setBool('isAuthenticated', false);
    await prefs.remove('username');
    await prefs.remove('token');
    await prefs.remove('unreadNotificationsCount');
    await prefs.remove('lastNotificationsVisit');
    notifyListeners();
  }

  // Método mejorado para establecer el contador de notificaciones no leídas
  Future<void> setUnreadNotificationsCount(int count) async {
    if (_unreadNotificationsCount != count) {
      _unreadNotificationsCount = count;
      debugPrint("[AuthProvider] Actualizando contador de notificaciones: $count");
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('unreadNotificationsCount', count);
      
      notifyListeners();
    }
  }

  // Método para incrementar el contador (útil cuando llega una nueva notificación push)
  Future<void> incrementUnreadCount() async {
    await setUnreadNotificationsCount(_unreadNotificationsCount + 1);
  }

  // Método para resetear el contador (cuando el usuario visita la pantalla de notificaciones)
  Future<void> resetUnreadCount() async {
    await setUnreadNotificationsCount(0);
    await updateLastNotificationsVisit();
  }

  // Método para actualizar la última visita con la fecha actual
  Future<void> updateLastNotificationsVisit() async {
    _lastNotificationsVisit = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'lastNotificationsVisit', 
      _lastNotificationsVisit!.toIso8601String()
    );
    debugPrint("[AuthProvider] Última visita actualizada: $_lastNotificationsVisit");
    notifyListeners();
  }

  // Método para manejar cuando el usuario ve las notificaciones
  Future<void> markNotificationsAsRead() async {
    await resetUnreadCount();
  }

  // Método para actualizar el contador basado en una lista de notificaciones
  Future<void> updateUnreadCountBasedOnNotifications(List<dynamic> notifications) async {
    if (!_isAuthenticated) return;
    
    if (_lastNotificationsVisit == null) {
      // Si nunca ha visitado, todas las notificaciones son nuevas
      await setUnreadNotificationsCount(notifications.length);
      return;
    }

    int newCount = 0;
    for (final notification in notifications) {
      final timestamp = notification['timestamp']?.toString();
      if (timestamp != null) {
        final notificationDate = DateTime.parse(timestamp);
        if (notificationDate.isAfter(_lastNotificationsVisit!)) {
          newCount++;
        }
      }
    }

    await setUnreadNotificationsCount(newCount);
  }
}