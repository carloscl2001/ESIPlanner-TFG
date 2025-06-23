import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'register_logic.dart';

// Campos del formulario
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;
  final FormFieldValidator<String>? validator;

  const EmailField({
    super.key,
    required this.controller,
    required this.isDarkMode,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(
          Icons.email,
          color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator ?? (value) => RegisterLogic(context).validateEmail(value),
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
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Nombre de usuario',
        prefixIcon: Icon(
          Icons.person,
          color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) => RegisterLogic(context).validateUsername(value),
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
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: Icon(
          Icons.lock,
          color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) => RegisterLogic(context).validatePassword(value),
    );
  }
}

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;
  final String label;

  const NameField({
    super.key,
    required this.controller,
    required this.isDarkMode,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          label == 'Nombre' ? Icons.badge : Icons.family_restroom,
          color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) => 
          RegisterLogic(context).validateName(value, label.toLowerCase()),
    );
  }
}

class DegreeDropdown extends StatelessWidget {
  final List<String> degrees;
  final String? selectedDegree;
  final bool isDarkMode;
  final ValueChanged<String?> onChanged;

  const DegreeDropdown({
    super.key,
    required this.degrees,
    required this.selectedDegree,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return degrees.isNotEmpty
        ? DropdownButtonFormField<String>(
            value: selectedDegree ?? degrees.first,
            onChanged: onChanged,
            decoration: InputDecoration(
              labelText: 'Grado',
              prefixIcon: Icon(
                Icons.school,
                color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            isExpanded: true, // Permite que el dropdown ocupe todo el ancho disponible
            selectedItemBuilder: (BuildContext context) {
              return degrees.map<Widget>((String value) {
                final isDefaultValue = selectedDegree == null && value == degrees.first;
                return SizedBox(
                  width: MediaQuery.of(context).size.width - 100, // Ajusta según necesidad
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis, // Añade puntos suspensivos si el texto es muy largo
                    style: TextStyle(
                      color: isDefaultValue 
                          ? Colors.grey.shade600
                          : (isDarkMode ? AppColors.blanco : AppColors.negro),
                    ),
                  ),
                );
              }).toList();
            },
            items: degrees.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

class DepartmentDropdown extends StatelessWidget {
  final List<String> departments;
  final String? selectedDepartment;
  final bool isDarkMode;
  final ValueChanged<String?> onChanged;

  const DepartmentDropdown({
    super.key,
    required this.departments,
    required this.selectedDepartment,
    required this.isDarkMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Valor efectivo que se mostrará
    final effectiveValue = (selectedDepartment != null && selectedDepartment!.isNotEmpty)
        ? selectedDepartment
        : (departments.isNotEmpty ? departments.first : null);

    return departments.isNotEmpty
        ? DropdownButtonFormField<String>(
            value: effectiveValue, // Siempre tendrá un valor válido aquí
            onChanged: (value) {
              // Cuando cambia, actualiza el valor en el logic
              onChanged(value ?? departments.first);
            },
            decoration: InputDecoration(
              labelText: 'Departamento',
              prefixIcon: Icon(
                Icons.business,
                color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: departments.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
        : const Center(child: CircularProgressIndicator());
  }
}

// Botones
class RegisterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDarkMode;

  const RegisterButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.blanco)
            : Text(
                'Registrarse',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.negro : AppColors.blanco 
                ),
              ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final bool isDarkMode;

  const LoginButton({
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
      style: TextButton.styleFrom(
        foregroundColor: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
      ),
      child: const Text(
        "¿Ya tienes una cuenta? Inicia sesión aquí",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Mensajes de error
class ErrorMessage extends StatelessWidget {
  final String message;

  const ErrorMessage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Formulario principal
class RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final RegisterLogic logic;
  final bool isDarkMode;
  final VoidCallback onRegisterPressed;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.logic,
    required this.isDarkMode,
    required this.onRegisterPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color.fromARGB(255, 24, 24, 24), const Color.fromARGB(255, 24, 24, 24)]
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
              children: [
                const SizedBox(height: 20),
                Text(
                  'Registrarse',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
                  ),
                ),
                const SizedBox(height: 20),
                EmailField(controller: logic.emailController, isDarkMode: isDarkMode),
                const SizedBox(height: 20),
                UsernameField(controller: logic.usernameController, isDarkMode: isDarkMode),
                const SizedBox(height: 20),
                PasswordField(controller: logic.passwordController, isDarkMode: isDarkMode),
                const SizedBox(height: 20),
                NameField(
                  controller: logic.nameController,
                  isDarkMode: isDarkMode,
                  label: 'Nombre',
                ),
                const SizedBox(height: 20),
                NameField(
                  controller: logic.surnameController,
                  isDarkMode: isDarkMode,
                  label: 'Apellido',
                ),
                const SizedBox(height: 20),
                UserTypeSelector(
                  isDarkMode: isDarkMode,
                  selectedType: logic.userType,
                  onChanged: (type) {
                    logic.setUserType(type);
                  },
                ),
                const SizedBox(height: 18),
                if (logic.userType == 'student')
                  DegreeDropdown(
                    degrees: logic.degrees,
                    selectedDegree: logic.selectedDegree,
                    isDarkMode: isDarkMode,
                    onChanged: (value) => logic.selectedDegree = value,
                  ),
                if (logic.userType == 'teacher')
                  DepartmentDropdown(
                    departments: logic.departments,
                    selectedDepartment: logic.selectedDepartment,
                    isDarkMode: isDarkMode,
                    onChanged: (value) => logic.selectedDepartment = value,
                  ),
                const SizedBox(height: 24),
                RegisterButton(
                  onPressed: onRegisterPressed,
                  isLoading: isLoading,
                  isDarkMode: isDarkMode,
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


class UserTypeSelector extends StatelessWidget {
  final bool isDarkMode;
  final String selectedType;
  final ValueChanged<String> onChanged;

  const UserTypeSelector({
    super.key,
    required this.isDarkMode,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4),
          child: Text(
            'Tipo de usuario',
            style: TextStyle(
              color: isDarkMode? AppColors.blanco : AppColors.azulIntermedioUCA, // Texto azul como pediste
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : AppColors.blanco, // Fondo blanco/negro
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDarkMode ? AppColors.amarillo : AppColors.azulIntermedioUCA, // Borde azul como pediste
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: _buildOption(
                  label: 'Estudiante',
                  icon: Icons.school,
                  selected: selectedType == 'student',
                  onTap: () => onChanged('student'),
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildOption(
                  label: 'Docente',
                  icon: Icons.person,
                  selected: selectedType == 'teacher',
                  onTap: () => onChanged('teacher'),
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? (isDarkMode ? AppColors.amarillo : AppColors.azulUCA ) // Mantengo tus colores originales
              : (isDarkMode ? AppColors.amarillo.withValues(alpha: 0.2) : Colors.indigo.shade100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected 
                  ? isDarkMode ? AppColors.negro : AppColors.blanco 
                  : (isDarkMode ? AppColors.amarilloClaro  : AppColors.azulIntermedioUCA), // Mantengo tus colores originales
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected 
                    ? isDarkMode ? AppColors.negro : AppColors.blanco 
                    : (isDarkMode ? AppColors.amarilloClaro : AppColors.azulIntermedioUCA),// Mantengo tus colores originales
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}