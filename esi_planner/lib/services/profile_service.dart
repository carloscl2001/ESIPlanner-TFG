import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileService {
  // Función que hace la solicitud HTTP para obtener el perfil
  Future<Map<String, dynamic>> getProfileData({required String username}) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/users/$username'),
      );

      if (response.statusCode == 200) {
        // Asegúrate de que el cuerpo de la respuesta se decodifique en UTF-8
        String responseBody = utf8.decode(response.bodyBytes);
        
        // Decodifica el JSON de la respuesta
        return json.decode(responseBody);
      } else {
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

  Future<Map<String, dynamic>> updatePassword({
  required String username,
  required String newPassword,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/auth/$username/changePassword'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'new_password': newPassword, // Usar 'new_password' como en la API
        }),
      );

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, devuelve un mensaje de éxito
        return {
          'success': true,
          'message': 'Contraseña actualizada correctamente'
        };
      } else if (response.statusCode == 400){
          //si la contraseña nueva es la misma que la anterior
         return {
          'success': false,
          'message': 'Contraseña nueva tiene que ser distinta a la anterior'
        };
      }else{
        // Si la respuesta es diferente a 200, devuelve un mensaje de error
        return {
          'success': false,
          'message': 'Error al actualizar la contraseña: ${response.body}'
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
