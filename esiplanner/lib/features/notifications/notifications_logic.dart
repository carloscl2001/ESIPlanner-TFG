import 'package:esiplanner/providers/auth_provider.dart';
import 'package:esiplanner/services/notifications_services.dart';
import 'package:esiplanner/services/profile_service.dart';
import 'package:esiplanner/services/subject_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class NotificationsLogic {
  final BuildContext context;
  final VoidCallback refreshUI;
  final Function(String) showError;
  final ProfileService profileService = ProfileService();
  final SubjectService subjectService = SubjectService();
  final NotificationsServices notificationsService = NotificationsServices();

  bool isLoading = true;
  bool isLoadingNotifications = false;
  List<dynamic> userSubjects = [];
  List<Map<String, dynamic>> userNotifications = [];
  String errorMessage = '';
  Map<String, String> subjectCodeMapping = {};

  NotificationsLogic({
    required this.context,
    required this.refreshUI,
    required this.showError,
  });

  Map<String, String> _createSubjectMapping(List<Map<String, dynamic>> mappingList) {
    final mapping = <String, String>{};
    for (var item in mappingList) {
      final code = item['code']?.toString();
      final codeIcs = item['code_ics']?.toString();
      if (code != null && codeIcs != null) {
        mapping[code] = codeIcs;
      }
    }
    return mapping;
  }

  Future<void> loadUserData() async {
    try {
      isLoading = true;
      refreshUI();
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final username = authProvider.username;

      if (username == null || username.isEmpty) {
        errorMessage = "El nombre de usuario no está disponible";
        isLoading = false;
        refreshUI();
        return;
      }

      // Cargar mapeo de asignaturas
      final mappingList = await subjectService.getSubjectMapping();
      subjectCodeMapping = _createSubjectMapping(mappingList);

      // Cargar asignaturas del usuario
      final response = await profileService.getUserSubjects(username: username);

      if (response['success'] == true) {
        userSubjects = await Future.wait(
          (response['data'] as List).map((subject) async {
            final code = subject['code']?.toString() ?? '';
            final codeIcs = subjectCodeMapping[code] ?? code;
            
            final subjectDetails = await subjectService.getSubjectData(
              codeSubject: codeIcs,
            );

            return {
              'code': code,
              'code_ics': codeIcs,
              'name': subjectDetails.isNotEmpty && subjectDetails.containsKey('name') 
                  ? subjectDetails['name']
                  : 'Asignatura $code',
              'groups': subject['groups_codes'] ?? [],
            };
          }).toList(),
        );

        await loadUserNotifications();
      } else {
        errorMessage = response['message'] ?? 'No se pudo obtener la información de las asignaturas';
      }
    } catch (e) {
      errorMessage = 'Error al cargar los datos: $e';
    } finally {
      isLoading = false;
      refreshUI();
    }
  }

  Future<void> loadUserNotifications() async {
    try {
      isLoadingNotifications = true;
      refreshUI();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final lastVisit = authProvider.lastNotificationsVisit;
      
      // Obtener códigos ICS de las asignaturas del usuario
      final userSubjectCodesIcs = userSubjects
          .where((sub) => sub['code_ics'] != null)
          .map((sub) => sub['code_ics'].toString())
          .toList();
      
      // Obtener notificaciones filtradas por asignaturas del usuario
      final filteredNotifications = await notificationsService.getNotifications(userSubjectCodesIcs);
      
      // Procesar notificaciones
      userNotifications = filteredNotifications.map((notification) {
        final sourceFile = notification['source_file']?.toString() ?? '';
        final fileCodeIcs = sourceFile.replaceAll('.json', '');
        final timestamp = notification['timestamp']?.toString() ?? '';
        
        final subject = userSubjects.firstWhere(
          (sub) => sub['code_ics']?.toString() == fileCodeIcs,
          orElse: () => {
            'code': fileCodeIcs, 
            'name': 'Asignatura desconocida',
            'code_ics': fileCodeIcs
          },
        );
        
        final notificationDate = DateTime.parse(timestamp);
        final isUnread = lastVisit == null || notificationDate.isAfter(lastVisit);

        return {
          'subject_code': subject['code'],
          'subject_name': subject['name'],
          'formatted_date': _formatTimestamp(timestamp),
          'raw_timestamp': timestamp,
          'operation': notification['operation']?.toString() ?? 'actualización',
          'message': notification['message']?.toString() ?? '',
          'is_unread': isUnread,
        };
      }).toList();

      userNotifications.sort((a, b) => b['raw_timestamp'].compareTo(a['raw_timestamp']));

      // Calcular el número de no leídas
      final unreadCount = userNotifications.where((n) => n['is_unread'] == true).length;
      authProvider.setUnreadNotificationsCount(unreadCount);
      
      // Mostrar alerta si hay nuevas notificaciones
      if (unreadCount > 0 && lastVisit != null) {
        _showNewNotificationsAlert(unreadCount);
      }

    } catch (e) {
      showError('Error al cargar notificaciones: $e');
      userNotifications = [];
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.setUnreadNotificationsCount(0);
    } finally {
      isLoadingNotifications = false;
      refreshUI();
    }
  }

  void _showNewNotificationsAlert(int newCount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newCount > 1 
            ? '¡Tienes $newCount nuevos avisos!' 
            : '¡Tienes un nuevo aviso!',
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime.toLocal());
    } catch (e) {
      return timestamp;
    }
  }

  Future<void> refreshAllData() async {
    await loadUserData();
  }
}