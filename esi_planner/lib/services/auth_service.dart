import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000'; // URL base de la API usando el emulador de Android
  //final String baseUrl = 'http://127.0.0.1:8000'; // URL base de la API para el resto

  // Método para registrar un usuario
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String name,
    required String surname,
    required String degree,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
          'name': name,
          'surname': surname,
          'degree': degree,
        }),
      );

      if (response.statusCode == 201) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': jsonDecode(response.body)['detail'] ?? 'Error desconocido',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error de conexión: $e',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        // Login exitoso
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        // Login fallido: decodifica el mensaje de error
        final errorMessage = jsonDecode(response.body)['detail'] ?? 'Error desconocido';
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      // Error de conexión o excepción
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}
