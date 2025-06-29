import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_services.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class NotificationsServices {
  final String baseUrl = ApiServices.baseUrl;

  // Método para obtener las notificaciones/logs del sistema filtradas por asignaturas del usuario
  Future<List<Map<String, dynamic>>> getNotifications(
    List<String> userSubjectCodesIcs,
  ) async {
    final url = Uri.parse('$baseUrl/logs/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final utf8DecodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = json.decode(utf8DecodedBody);

      // Filtrar y mapear las notificaciones
      return data
          .where((notification) {
            // Obtener el código de la asignatura del nombre del archivo
            final sourceFile = notification['source_file']?.toString() ?? '';
            final fileCode = sourceFile.replaceAll('.json', '');
            
            // Verificar si es una asignatura del usuario
            return userSubjectCodesIcs.contains(fileCode);
          })
          .map<Map<String, dynamic>>((notification) {
            return {
              'source_file': notification['source_file'],
              'timestamp': notification['timestamp'],
              'operation': notification['operation'],
              'message': notification['message'],
            };
          })
          .toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // Método para obtener solo el conteo de notificaciones no leídas
  Future<int> getUnreadNotificationsCount(
    BuildContext context,
    List<String> userSubjectCodesIcs,
  ) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final lastVisit = authProvider.lastNotificationsVisit;
      
      if (lastVisit == null) return 0;

      final notifications = await getNotifications(userSubjectCodesIcs);
      
      return notifications.where((notification) {
        final timestamp = notification['timestamp']?.toString() ?? '';
        final notificationDate = DateTime.parse(timestamp);
        return notificationDate.isAfter(lastVisit);
      }).length;
    } catch (e) {
      return 0;
    }
  }
}