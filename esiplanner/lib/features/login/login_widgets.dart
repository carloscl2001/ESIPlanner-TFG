import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'login_logic.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final LoginLogic logic;
  final bool isDarkMode;
  final VoidCallback onLoginPressed;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.logic,
    required this.isDarkMode,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 40),
          LoginCard(
            formKey: formKey,
            logic: logic,
            isDarkMode: isDarkMode,
            onLoginPressed: onLoginPressed,
          ),
          const SizedBox(height: 20),
          RegisterButton(isDarkMode: isDarkMode),
        ],
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final LoginLogic logic;
  final bool isDarkMode;
  final VoidCallback onLoginPressed;

  const LoginCard({
    super.key,
    required this.formKey,
    required this.logic,
    required this.isDarkMode,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? [
                      const Color.fromARGB(255, 24, 24, 24),
                      const Color.fromARGB(255, 24, 24, 24),
                    ]
                    : [AppColors.azulClaro2, AppColors.blanco],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
                  ),
                ),
                const SizedBox(height: 24),
                UsernameField(
                  controller: logic.usernameController,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 20),
                PasswordField(
                  controller: logic.passwordController,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 24),
                LoginButton(onPressed: onLoginPressed, isDarkMode: isDarkMode),
                if (logic.errorMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ErrorMessage(message: logic.errorMessage),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;

  const UsernameField({
    super.key,
    required this.controller,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('usernameField'),
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Usuario',
        prefixIcon: Icon(
          Icons.person,
          color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
        ),
      ),
      validator: (value) => LoginLogic(context).validateUsername(value),
    );
  }
}

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;

  const PasswordField({
    super.key,
    required this.controller,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('passwordField'),
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: Icon(
          Icons.lock,
          color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
        ),
      ),
      validator: (value) => LoginLogic(context).validatePassword(value),
    );
  }
}

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isDarkMode;

  const LoginButton({
    super.key,
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      key: const Key('loginButton'),
      onPressed: onPressed,
      child: Text(
        'Iniciar sesión',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? AppColors.negro : AppColors.blanco,
        ),
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(color: Colors.red, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}

class RegisterButton extends StatelessWidget {
  final bool isDarkMode;

  const RegisterButton({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/register');
      },
      style: TextButton.styleFrom(
        foregroundColor: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
      ),
      child: const Text(
        "¿No tienes una cuenta? Regístrate aquí",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
