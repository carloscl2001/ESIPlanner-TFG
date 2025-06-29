import 'package:esiplanner/shared/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ProfileMenuScreen extends StatelessWidget {
  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width >= 1024;
    final isMobile = !isDesktop;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Mi Perfil',
                  style: TextStyle(
                    fontSize: isDesktop ? 36 : 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
                  ),
                ),
                const SizedBox(height: 40),
                
                if (isMobile) _buildMobileLayout(context),
                if (isDesktop) _buildDesktopLayout(context),
                
                const SizedBox(height: 40),
                if (!isDesktop) const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      alignment: WrapAlignment.center,
      children: const [
        ProfileCard(
          text: 'Mi perfil',
          icon: Icons.person_pin,
          route: '/viewProfile',
        ),
        ProfileCard(
          text: 'Mis asignaturas',
          icon: Icons.menu_book_rounded,
          route: '/viewSubjects',
        ),
        ProfileCard(
          text: 'Seleccionar asignaturas',
          icon: Icons.touch_app_rounded,
          route: '/selectionSubjects',
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
  final screenSize = MediaQuery.of(context).size;
  final cardWidth = (screenSize.width * 0.5) - 30; // Ancho de cada card superior
  final spacing = 10.0; // Espacio entre las cards superiores
  final totalWidth = (cardWidth * 2) + spacing + 8; // Ancho total de ambas cards + espacio

  return Column(
    children: [
      // Primera fila con dos cards
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProfileCard(
            text: 'Mi perfil',
            icon: Icons.person_pin,
            route: '/viewProfile',
            isMobile: true,
            customWidth: cardWidth,
          ),
          SizedBox(width: spacing),
          ProfileCard(
            text: 'Mis asignaturas',
            icon: Icons.menu_book_rounded,
            route: '/viewSubjects',
            isMobile: true,
            customWidth: cardWidth,
          ),
        ],
      ),
      const SizedBox(height: 20),
      // Segunda fila con una card ancha
      ProfileCard(
        text: 'Seleccionar asignaturas',
        icon: Icons.touch_app_rounded,
        route: '/selectionSubjects',
        isMobile: true,
        customWidth: totalWidth, // Mismo ancho que las dos superiores juntas
      ),
    ],
  );
}
}

class ProfileCard extends StatefulWidget {
  final String text;
  final IconData icon;
  final String route;
  final bool isMobile;
  final double? customWidth; // Nuevo parámetro

  const ProfileCard({
    super.key,
    required this.text,
    required this.icon,
    required this.route,
    this.isMobile = false,
    this.customWidth, // Añadido aquí
  });

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;

    final cardWidth = widget.customWidth ?? // Usa el ancho personalizado si existe
        (widget.isMobile 
            ? (screenSize.width * 0.5) - 30
            : isDesktop ? 280.0 : 180.0);

    final cardHeight = widget.isMobile ? 160.0 : isDesktop ? 280.0 : 180.0;

    return MouseRegion(
      onEnter: (_) => !widget.isMobile ? setState(() => _isHovered = true) : null,
      onExit: (_) => !widget.isMobile ? setState(() => _isHovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..scale(!widget.isMobile && _isHovered ? 1.05 : 1.0)
          ..translate(0.0, !widget.isMobile && _isHovered ? -8.0 : 0.0),
        child: Card(
          elevation: !widget.isMobile && _isHovered ? 12 : 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          shadowColor: isDarkMode
              ? Colors.yellow.withValues(alpha:0.3)
              : Colors.indigo.withValues(alpha:0.3),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, widget.route),
            borderRadius: BorderRadius.circular(20.0),
            onHighlightChanged: (highlighted) {
              if (widget.isMobile) {
                setState(() => _isHovered = highlighted);
              }
            },
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? _isHovered
                          ? [Colors.grey[900]!, AppColors.negro]
                          : [Colors.grey[900]!, AppColors.negro]
                      : _isHovered
                          ? [AppColors.blanco, AppColors.blanco]
                          : [AppColors.blanco, AppColors.blanco],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode
                            ? Colors.yellow.withValues(alpha:_isHovered ? 0.2 : 0.1)
                            : Colors.indigo.withValues(alpha:_isHovered ? 0.2 : 0.1),
                      ),
                      child: Icon(
                        widget.icon,
                        size: widget.isMobile ? 32 : isDesktop ? 42 : 36,
                        color: isDarkMode
                            ? AppColors.amarilloClaro
                            : AppColors.azulUCA,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: widget.isMobile ? 16 : isDesktop ? 18 : 16,
                        color: isDarkMode ? AppColors.blanco : AppColors.azulUCA,
                      ),
                    ),
                    if (_isHovered && !widget.isMobile) ...[
                      SizedBox(height: isDesktop ? 40 : 5),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: isDarkMode
                            ? AppColors.amarilloClaro
                            : AppColors.azulUCA,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}