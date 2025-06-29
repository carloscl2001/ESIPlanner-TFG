import 'package:esiplanner/features/notifications/notifications_logic.dart';
import 'package:esiplanner/features/notifications/notifications_widgets.dart';
import 'package:esiplanner/providers/auth_provider.dart';
import 'package:esiplanner/providers/theme_provider.dart';
import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationsLogic logic;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    logic = NotificationsLogic(
      context: context,
      refreshUI: () {
        if (_isMounted) {
          setState(() {});
        }
      },
      showError: (message) {
        if (_isMounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (_isMounted) {
        await logic.loadUserData();
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        // Registrar la visita actual
        await authProvider.updateLastNotificationsVisit();
        // Forzar recálculo de no leídas
        await logic.loadUserNotifications();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    if (logic.isLoading || logic.isLoadingNotifications) {
      return Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
        ),
      );
    }

    if (logic.errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            logic.errorMessage,
            style: TextStyle(
              color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (logic.userNotifications.isEmpty) {
      return BuildEmptyNotifications(isDarkMode: isDarkMode);
    }

    return RefreshIndicator(
      color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
      onRefresh: () => logic.refreshAllData(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        itemCount: logic.userNotifications.length,
        itemBuilder: (context, index) {
          final notification = logic.userNotifications[index];
          return NotificationCard(
            notification: notification,
            isDarkMode: isDarkMode,
          );
        },
      ),
    );
  }
}