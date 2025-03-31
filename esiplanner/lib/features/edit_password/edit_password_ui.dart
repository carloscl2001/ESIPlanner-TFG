import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'edit_password_widgets.dart';
import 'edit_password_logic.dart';

class EditPasswordUI extends StatefulWidget {
  const EditPasswordUI({super.key});

  @override
  State<EditPasswordUI> createState() => _EditPasswordUIState();
}

class _EditPasswordUIState extends State<EditPasswordUI> {
  late final EditPasswordLogic logic;

  @override
  void initState() {
    super.initState();
    logic = EditPasswordLogic(context, onStateChanged: () => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cambiar tu contraseña',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: EditPasswordForm(logic: logic, isDarkMode: isDarkMode),
      ),
    );
  }
}