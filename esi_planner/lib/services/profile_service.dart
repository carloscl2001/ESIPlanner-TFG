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
        // Asegúrate de que el cuerpo de la respuesta se decodifique en UTF-8
        String responseBody = utf8.decode(response.bodyBytes);
        
        // Decodifica el JSON de la respuesta
        return json.decode(responseBody);
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
