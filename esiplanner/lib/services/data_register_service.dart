
import 'dart:convert';
import 'api_services.dart';
import 'package:http/http.dart' as http;

class DataRegisterService{
  final String baseUrl = ApiServices.baseUrl;

  // Método para obtener los departamentos de la ESI y mostrarlos en el desplegable -> login_screen
  Future<List<String>> getDepartments() async {
    final url = Uri.parse('$baseUrl/departments/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(utf8DecodedBody);

      return data.map<String>((department) => department['name'].toString()).toList();
    } else {
      throw Exception('Failed to load departments');
    }
  }

  // Método para obtener los grados de la ESI y mostrarlos en el desplegable -> login_screen
  Future<List<String>> getDegrees() async {
    final url = Uri.parse('$baseUrl/degrees/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(utf8DecodedBody);

      return data.map<String>((degree) => degree['name'].toString()).toList();
    } else {
      throw Exception('Failed to load degrees');
    }
  }
}