import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'login_logic.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isDesktop 
          ? _buildDesktopLayout(context)
          : _buildMobileLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 20),
        LoginCard(
          formKey: formKey,
          logic: logic,
          isDarkMode: isDarkMode,
          onLoginPressed: onLoginPressed,
        ),
        const SizedBox(height: 20),
        RegisterButton(isDarkMode: isDarkMode),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10, // 5% del ancho de pantalla
          vertical: 10,   // 3% del alto de pantalla
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                    height: screenHeight * 0.45, // 40% del alto de pantalla
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Bienvenido de nuevo!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 550,
                    child: Text(
                      'Visualiza tu calendario académico de forma sencilla y rápida.',
                      style: TextStyle(
                        fontSize: 18,
                        color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: screenWidth * 0.05), // 5% del ancho de pantalla
            IntrinsicWidth(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
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
            ),
          ],
        ),
      ),
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
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        width: isDesktop ? 500 : null,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [
                    const Color.fromARGB(255, 24, 24, 24),
                    const Color.fromARGB(255, 24, 24, 24),
                  ]
                : [AppColors.azulClaro2, AppColors.azulClaro2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: EdgeInsets.all( 24.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: isDesktop ? 10 : 2),
                isDesktop ? Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
                  ),
                ) : SvgPicture.asset(
                  'assets/logo.svg',
                  height: 200,
                  fit: BoxFit.contain,
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
                SizedBox(
                  width: isDesktop ? double.infinity : null,
                  child: LoginButton(
                    onPressed: onLoginPressed, 
                    isDarkMode: isDarkMode
                  ),
                ),
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
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
    return TextFormField(
      key: const Key('usernameField'),
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Usuario',
        prefixIcon: Icon(
          Icons.person,
          color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
        ),
        contentPadding: isDesktop 
            ? const EdgeInsets.symmetric(vertical: 16, horizontal: 20)
            : null,
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
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
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
        contentPadding: isDesktop 
            ? const EdgeInsets.symmetric(vertical: 16, horizontal: 20)
            : null,
      ),
      validator: (value) => LoginLogic(context).validatePassword(value),
    );
  }
}

class LoginButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDarkMode;

  const LoginButton({
    super.key,
    required this.onPressed,
    required this.isDarkMode,
  });

  @override
  _LoginButtonState createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _scale = 1.05),
      onExit: (_) => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          key: const Key('loginButton'),
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            padding: isDesktop 
                ? const EdgeInsets.symmetric(vertical: 20, horizontal: 20)
                : null,
            backgroundColor: widget.isDarkMode ? AppColors.blanco : AppColors.azulUCA,
          ),
          child: Text(
            'Iniciar sesión',
            style: TextStyle(
              fontSize: isDesktop ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: widget.isDarkMode ? AppColors.negro : AppColors.blanco,
            ),
          ),
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