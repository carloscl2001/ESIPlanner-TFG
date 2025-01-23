import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';  // Importa el AuthProvider para acceder al token

class SubjectService {
  //Funcion que hace la solictud HTTP para obtner los datos de una asignatura
  Future<Map<String, dynamic>> getSubjectData({
    required String codeSubject}) async {
      try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/subjects/$codeSubject'),
      );

      if (response.statusCode == 200) {
        // Asegúrate de que el cuerpo de la respuesta se decodifique en UTF-8
        String responseBody = utf8.decode(response.bodyBytes);
        
        // Decodifica el JSON de la respuesta
        return json.decode(responseBody);
      } else {
        return {
          'success': false,
          'message': 'Asignatura no encontrada'
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