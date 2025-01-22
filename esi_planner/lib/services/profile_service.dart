import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileService {
  // Función que hace la solicitud HTTP para obtener el perfil
  Future<Map<String, dynamic>> getProfileData({required String username}) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/users/$username'), // Asegúrate de usar la URL correcta
      );

      if (response.statusCode == 200) {
        // Si la llamada a la API fue exitosa, devuelve los datos
        return json.decode(response.body);
      } else {
        // Si la respuesta es diferente a 200, devuelve un mensaje de error
        return {
          'success': false,
          'message': 'Error al obtener los datos del perfil'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al realizar la solicitud: $e'
      };
    }
  }
}
