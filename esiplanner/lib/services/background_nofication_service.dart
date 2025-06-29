import 'package:esiplanner/providers/auth_provider.dart';
import 'package:esiplanner/services/notifications_services.dart';
import 'package:esiplanner/services/profile_service.dart';
import 'package:esiplanner/services/subject_service.dart';

class BackgroundNotificationService {
  final NotificationsServices _notificationsService = NotificationsServices();
  final ProfileService _profileService = ProfileService();
  final SubjectService _subjectService = SubjectService();

  Future<void> checkForNewNotifications(AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated || authProvider.username == null) return;

    try {
      // Obtener las asignaturas del usuario
      final username = authProvider.username!;
      final response = await _profileService.getUserSubjects(username: username);
      
      if (response['success'] != true) return;

      // Obtener el mapeo de códigos
      final mappingList = await _subjectService.getSubjectMapping();
      final subjectCodeMapping = _createSubjectMapping(mappingList);

      // Obtener códigos ICS de las asignaturas del usuario
      final userSubjectCodesIcs = (response['data'] as List)
          .where((sub) => sub['code'] != null)
          .map((sub) => subjectCodeMapping[sub['code'].toString()] ?? sub['code'].toString())
          .toList();

      // Obtener notificaciones filtradas
      final filteredNotifications = await _notificationsService.getNotifications(userSubjectCodesIcs);
      
      final lastVisit = authProvider.lastNotificationsVisit;
      int newNotificationsCount = 0;
      
      for (final notification in filteredNotifications) {
        final timestamp = notification['timestamp']?.toString() ?? '';
        if (timestamp.isNotEmpty) {
          final notificationDate = DateTime.parse(timestamp);
          if (lastVisit == null || notificationDate.isAfter(lastVisit)) {
            newNotificationsCount++;
          }
        }
      }

      authProvider.setUnreadNotificationsCount(newNotificationsCount);
    } catch (e) {
      // print('Error checking notifications: $e');
      authProvider.setUnreadNotificationsCount(0);
    }
  }

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
}