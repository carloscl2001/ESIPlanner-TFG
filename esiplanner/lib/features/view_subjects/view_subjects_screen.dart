import 'package:esiplanner/providers/theme_provider.dart';
import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'view_subjects_logic.dart';
import 'view_subjects_widgets.dart';

class ViewSubjectsScreen extends StatefulWidget {
  const ViewSubjectsScreen({super.key});

  @override
  State<ViewSubjectsScreen> createState() => _ViewSubjectsScreenState();
}

class _ViewSubjectsScreenState extends State<ViewSubjectsScreen> {
  late ViewSubjectsProfileLogic logic;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    logic = ViewSubjectsProfileLogic(
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) {
        logic.loadUserSubjects(context);
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

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.gris1_2 : AppColors.azulClaro2,
      appBar: AppBar(
        title: const Text('Mis asignaturas'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDarkMode ? AppColors.gris1 : AppColors.azulUCA,
        iconTheme: IconThemeData(
          color: isDarkMode ? AppColors.amarillo : AppColors.blanco,
        ),
        titleTextStyle: TextStyle(
          color: isDarkMode ? AppColors.amarillo : AppColors.blanco,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _buildBody(isDarkMode),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (logic.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDarkMode ? AppColors.amarillo : AppColors.azul,
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
              color: isDarkMode ? AppColors.amarillo : AppColors.azul,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (logic.userSubjects.isEmpty) {
      return const BuildEmptyCard();
    }

    return RefreshIndicator(
      color: isDarkMode ? AppColors.amarillo : AppColors.azul,
      onRefresh: () => logic.loadUserSubjects(context),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        itemCount: logic.userSubjects.length,
        itemBuilder: (context, index) {
          return SubjectCard(
            subject: logic.userSubjects[index],
            isDarkMode: isDarkMode,
            logic: logic,
          );
        },
      ),
    );
  }
}