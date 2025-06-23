import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'edit_password_widgets.dart';
import 'edit_password_logic.dart';

class EditPasswordScreen extends StatefulWidget {
  const EditPasswordScreen({super.key});

  @override
  State<EditPasswordScreen> createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  late final EditPasswordLogic logic;

  @override
  void initState() {
    super.initState();
    logic = EditPasswordLogic();
  }

  @override
  void dispose() {
    logic.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    await logic.updatePassword(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis clases de la semana'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 10,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.negro : AppColors.azulUCA,
          ),
        ),
      ),
      body: Center(
        child: EditPasswordForm(
          logic: logic,
          isDarkMode: isDarkMode,
          onUpdate: _handleUpdate,
        ),
      ),
    );
  }
}