import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';

class ViewProfileWidgets extends StatelessWidget {
  final bool isDarkMode;
  final String errorMessage;
  final Map<String, dynamic> userProfile;

  const ViewProfileWidgets({
    super.key,
    required this.isDarkMode,
    required this.errorMessage,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final cardWidth = isDesktop ? 600.0 : double.infinity;
    final isStudent = userProfile['degree'] != null;
    final role = isStudent ? 'Estudiante' : 'Docente';
    final roleIcon = isStudent ? Icons.school : Icons.work;

    return Center(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [AppColors.negro, AppColors.negro]
                    : [AppColors.azulClaro1, AppColors.azulClaro2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Header con indicador de rol
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade800 : AppColors.azulUCA,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        roleIcon,
                        color: isDarkMode ? AppColors.amarillo : AppColors.blanco,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? AppColors.blanco : AppColors.blanco,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(isDesktop ? 30.0 : 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (errorMessage.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: isDesktop ? 16.0 : 14.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: isDesktop ? 30.0 : 20.0),
                      ],

                      ProfileField(
                        icon: Icons.badge,
                        label: userProfile['username'] ?? 'Cargando...',
                        isDarkMode: isDarkMode,
                        isDesktop: isDesktop,
                      ),
                      ProfileField(
                        icon: Icons.email,
                        label: userProfile['email'] ?? 'Cargando...',
                        isDarkMode: isDarkMode,
                        isDesktop: isDesktop,
                      ),
                      ProfileField(
                        icon: Icons.person,
                        label: userProfile['name'] ?? 'Cargando...',
                        isDarkMode: isDarkMode,
                        isDesktop: isDesktop,
                      ),
                      ProfileField(
                        icon: Icons.family_restroom,
                        label: userProfile['surname'] ?? 'Cargando...',
                        isDarkMode: isDarkMode,
                        isDesktop: isDesktop,
                      ),
                      ProfileField(
                        icon: isStudent ? Icons.school : Icons.business,
                        label: isStudent 
                            ? userProfile['degree'] ?? 'Cargando...'
                            : userProfile['department'] ?? 'Cargando...',
                        isDarkMode: isDarkMode,
                        isDesktop: isDesktop,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDarkMode;
  final bool isDesktop;

  const ProfileField({
    super.key,
    required this.icon,
    required this.label,
    required this.isDarkMode,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: isDesktop ? 10 : 8.0),
      padding: EdgeInsets.all(isDesktop ? 18.0 : 16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : AppColors.blanco,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.negro.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isDesktop ? 8 : 0),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800 : AppColors.azulClaro2,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isDesktop ? 24.0 : 20.0,
              color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
            ),
          ),
          SizedBox(width: isDesktop ? 16.0 : 12.0),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isDesktop ? 16.0 : 16.0,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.blanco : AppColors.negro,
              ),
            ),
          ),
        ],
      ),
    );
  }
}