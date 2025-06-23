import 'package:esiplanner/services/data_register_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class RegisterLogic with ChangeNotifier {
  final BuildContext context;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  
  String errorMessage = "";
  List<String> degrees = [];
  List<String> departments = [];
  String? selectedDegree;
  String? selectedDepartment;
  String userType = 'student'; // 'student' or 'teacher'
  bool isLoading = false;

  RegisterLogic(this.context);

  Future<void> loadData() async {
    try {
      isLoading = true;
      notifyListeners();
      
      final dataRegisterService = DataRegisterService();
      degrees = await dataRegisterService.getDegrees();
      departments = await dataRegisterService.getDepartments();
      
      if (userType == 'student') {
        selectedDegree = degrees.isNotEmpty ? degrees[0] : null;
      } else { // teacher
        selectedDepartment = departments.isNotEmpty ? departments.first : null;
      }
      
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Error al cargar los datos';
      isLoading = false;
      notifyListeners();
    }
}

  void setUserType(String type) {
    userType = type;
    notifyListeners();
  }

  Future<bool> register() async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();

      final authService = AuthService();
      dynamic result;

      if (userType == 'student') {
        result = await authService.register(
          email: emailController.text.trim(),
          username: usernameController.text.trim(),
          password: passwordController.text.trim(),
          name: nameController.text.trim(),
          surname: surnameController.text.trim(),
          degree: selectedDegree ?? '',
        );
      } else { // teacher
        // Asegura que siempre haya un departamento seleccionado
        final department = selectedDepartment?.isNotEmpty ?? false 
            ? selectedDepartment!
            : departments.isNotEmpty 
                ? departments.first 
                : '';

        result = await authService.register(
          email: emailController.text.trim(),
          username: usernameController.text.trim(),
          password: passwordController.text.trim(),
          name: nameController.text.trim(),
          surname: surnameController.text.trim(),
          department: department,
        );
      }

      isLoading = false;

      if (context.mounted) {
        context.read<AuthProvider>().register(usernameController.text, result['token']);
      }
      
      notifyListeners();
      return result['success'];
    } catch (e) {
      errorMessage = 'Error durante el registro: ${e.toString()}';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Validators
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Por favor ingrese un email';
    if (!isValidEmail(value)) return 'Ingrese un email válido';
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'Por favor ingrese un nombre de usuario';
    if (value.length < 4) return 'Debe tener al menos 4 caracteres';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Por favor ingrese una contraseña';
    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) return 'Por favor ingrese su $fieldName';
    if (value.length < 2) return 'Debe tener al menos 2 caracteres';
    return null;
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void dispose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    surnameController.dispose();
    super.dispose();
  }
}