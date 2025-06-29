import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final bool isDarkMode;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final textColor = isDarkMode ? AppColors.blanco : AppColors.negro;
    final secondaryTextColor = isDarkMode ? AppColors.blanco70 : AppColors.negro54;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: isMobile ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.gris1 : AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fecha y hora en la misma línea
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (notification['formatted_date'] ?? 'Fecha desconocida').split(' ').first,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatTime(notification['raw_timestamp']),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // Contenido principal
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono de notificación
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDarkMode ? AppColors.amarillo : AppColors.azulUCA)
                        .withValues(alpha:0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    size: isMobile ? 18 : 24,
                    color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                  ),
                ),
                
                SizedBox(width: isMobile ? 10 : 18),
                
                // Texto de la notificación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['subject_name'] ?? 'Asignatura desconocida',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                     SizedBox(width: isMobile ? 6 : 10),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Mantenemos igual
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.gris2 : AppColors.azulClaro2,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
                            width: 1,
                          ),
                        ),
                        child: Text(
                        notification['subject_code'] ?? 'COD',
                          style: TextStyle(
                            color: isDarkMode ? AppColors.amarilloClaro : AppColors.azulUCA,
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 14 : 16, // Ajustado para mobile
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Ha sufrido una modificación. ¡Revise su calendario!',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return DateFormat('HH:mm').format(dateTime.toLocal());
    } catch (e) {
      return '';
    }
  }
}

class BuildEmptyNotifications extends StatelessWidget {
  final bool isDarkMode;

  const BuildEmptyNotifications({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final textColor = isDarkMode ? AppColors.blanco70 : AppColors.negro54;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: isMobile ? 80.0 : 100.0,
            color: textColor.withValues(alpha:0.7),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay avisos!',
            style: TextStyle(
              fontSize: isMobile ? 20.0 : 24.0,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Tus asignaturas no han sufrido modificaciones.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 14.0 : 16.0,
                color: textColor.withValues(alpha:0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}