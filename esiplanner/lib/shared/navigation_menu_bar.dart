import 'package:esiplanner/features/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../features/my_week/my_week_screen.dart';
import '../features/timetable/timetable_principal/timetable_principal_screen.dart';
import '../non_features/profile_menu_screen.dart';
import '../providers/theme_provider.dart';
import 'app_colors.dart';

class NavigationMenuBar extends StatefulWidget {
  const NavigationMenuBar({super.key});

  @override
  State<NavigationMenuBar> createState() => _NavigationMenuBarState();
}

class _NavigationMenuBarState extends State<NavigationMenuBar> {
  int currentPageIndex = 0;
  bool _isHoveringSidebar = false;
  int? _hoveredItemIndex;

  void logout() {
    context.read<AuthProvider>().logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void showSettingsMenu(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    bool isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: Text(
                  isDarkMode ? 'Modo Oscuro' : 'Modo Claro',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                secondary: Icon(
                  isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  color: isDarkMode ? AppColors.blanco : AppColors.amarillo,
                ),
                value: isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                  Navigator.pop(context);
                },
                activeColor: AppColors.amarillo,
                inactiveThumbColor: AppColors.azulUCA,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.password_rounded, color: Colors.red),
                title: const Text(
                  'Cambiar contraseña',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/editPassWord');
                },              
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Cerrar sesión',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  logout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required bool isDarkMode,
    int? notificationCount,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        NavigationDestination(
          selectedIcon: Icon(
            selectedIcon,
            color: isDarkMode ? AppColors.amarillo : AppColors.azulUCA,
          ),
          icon: Icon(icon, color: Colors.grey),
          label: label,
        ),
        if (notificationCount != null && notificationCount > 0)
          Positioned(
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.amarilloUCA,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode ? AppColors.negro : AppColors.blanco,
                  width: 2,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                notificationCount > 9 ? '9+' : notificationCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDesktopNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isExpanded,
    required Color accentColor,
    required bool isSelected,
    required Color hoverColor,
    int? notificationCount,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredItemIndex = index),
      onExit: (_) => setState(() => _hoveredItemIndex = null),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _hoveredItemIndex == index ? 1.05 : 1.0,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.2)
                    : _hoveredItemIndex == index
                        ? hoverColor
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => currentPageIndex = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  child: Row(
                    mainAxisAlignment: isExpanded 
                        ? MainAxisAlignment.start 
                        : MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 100),
                        scale: _hoveredItemIndex == index ? 1.05 : 1.0,
                        child: Icon(
                          icon,
                          color: isSelected || _hoveredItemIndex == index
                              ? accentColor
                              : accentColor.withValues(alpha: 0.8),
                          size: _hoveredItemIndex == index ? 26 : 24,
                        ),
                      ),
                      if (isExpanded) ...[
                        const SizedBox(width: 15),
                        AnimatedOpacity(
                          opacity: isExpanded ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 100),
                            style: TextStyle(
                              color: isSelected || _hoveredItemIndex == index
                                  ? accentColor
                                  : accentColor.withValues(alpha: 0.9),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: _hoveredItemIndex == index ? 18 : 16,
                            ),
                            child: Text(label),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (notificationCount != null && notificationCount > 0)
              Positioned(
                right: isExpanded ? 8 : 5,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.amarilloUCA,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.negro54,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    notificationCount > 9 ? '9+' : notificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: ClipRRect(
          child: SvgPicture.asset(
            'assets/logo_blanco_sin_letras.svg',
            height: 40,
            colorFilter: ColorFilter.mode(
              AppColors.blanco,
              BlendMode.srcIn,
            ),
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          Transform.translate(
            offset: const Offset(-6, 0),
            child: IconButton(
              icon: const Icon(Icons.settings_rounded, size: 26),
              onPressed: () => showSettingsMenu(context),
              color: isDarkMode ? AppColors.amarillo : AppColors.blanco,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.negro.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          color: isDarkMode ? AppColors.negro : AppColors.blanco,
        ),
        child: NavigationBar(
          backgroundColor: isDarkMode ? AppColors.negro : AppColors.blanco,
          surfaceTintColor: Colors.transparent,
          indicatorColor: isDarkMode
              ? Colors.yellow.withValues(alpha: 0.2)
              : Colors.indigo.shade100,
          onDestinationSelected: (int index) {
            setState(() => currentPageIndex = index);
          },
          selectedIndex: currentPageIndex,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: <Widget>[
            _buildNavigationDestination(
              icon: Icons.view_week_outlined,
              selectedIcon: Icons.view_week,
              label: 'Mi semana',
              index: 0,
              isDarkMode: isDarkMode,
            ),
            _buildNavigationDestination(
              icon: Icons.calendar_month_outlined,
              selectedIcon: Icons.calendar_month_rounded,
              label: 'Calendario',
              index: 1,
              isDarkMode: isDarkMode,
            ),
            _buildNavigationDestination(
              icon: Icons.notifications_outlined,
              selectedIcon: Icons.notifications,
              label: 'Avisos',
              index: 2,
              isDarkMode: isDarkMode,
              notificationCount: authProvider.getUnreadNotificationsCount,
            ),
            _buildNavigationDestination(
              icon: Icons.person_outline,
              selectedIcon: Icons.person,
              label: 'Perfil',
              index: 3,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: <Widget>[
          const MyWeekScreen(),
          const TimetablePrincipalScreen(),
          const NotificationsScreen(),
          const ProfileMenuScreen(),
        ][currentPageIndex],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final drawerColor = isDarkMode ? AppColors.negro : AppColors.azulUCA;
    final accentColor = isDarkMode ? Colors.amber.shade400 : AppColors.blanco;
    final hoverColor = isDarkMode 
        ? Colors.amber.withValues(alpha: 0.15) 
        : AppColors.blanco.withValues(alpha: 0.25);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Row(
        children: [
          // Barra lateral de navegación
          MouseRegion(
            onEnter: (_) => setState(() => _isHoveringSidebar = true),
            onExit: (_) => setState(() {
              _isHoveringSidebar = false;
              _hoveredItemIndex = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              width: _isHoveringSidebar ? 215 : 100,
              decoration: BoxDecoration(
                color: drawerColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.negro.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 30, bottom: 30),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoveredItemIndex = -2),
                      onExit: (_) => setState(() => _hoveredItemIndex = null),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: _hoveredItemIndex == -2 ? 1.1 : 1.0,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _isHoveringSidebar
                              ? ClipRRect(
                                  child: SvgPicture.asset(
                                    'assets/logo_blanco_con_letras.svg',
                                    colorFilter: ColorFilter.mode(
                                      AppColors.blanco,
                                      BlendMode.srcIn,
                                    ),
                                    height: 150,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : ClipRRect(
                                  child: SvgPicture.asset(
                                    'assets/logo_blanco_con_letras.svg',
                                    colorFilter: ColorFilter.mode(
                                      AppColors.blanco,
                                      BlendMode.srcIn,
                                    ),
                                    height: 75,
                                    fit: BoxFit.contain,
                                  ),
                                )
                        ),
                      ),
                    ),
                  ),
      
                  Expanded(
                    child: ListView(
                      padding: _isHoveringSidebar ? EdgeInsets.zero : const EdgeInsets.only(top: 75),
                      children: [
                        _buildDesktopNavItem(
                          context,
                          icon: Icons.view_week_rounded,
                          label: 'Mi semana',
                          index: 0,
                          isExpanded: _isHoveringSidebar,
                          accentColor: accentColor,
                          isSelected: currentPageIndex == 0,
                          hoverColor: hoverColor,
                        ),
                        _buildDesktopNavItem(
                          context,
                          icon: Icons.calendar_month_rounded,
                          label: 'Calendario',
                          index: 1,
                          isExpanded: _isHoveringSidebar,
                          accentColor: accentColor,
                          isSelected: currentPageIndex == 1,
                          hoverColor: hoverColor,
                        ),
                        _buildDesktopNavItem(
                          context,
                          icon: Icons.notifications_rounded,
                          label: 'Avisos',
                          index: 2,
                          isExpanded: _isHoveringSidebar,
                          accentColor: accentColor,
                          isSelected: currentPageIndex == 2,
                          hoverColor: hoverColor,
                          notificationCount: authProvider.getUnreadNotificationsCount,
                        ),
                        _buildDesktopNavItem(
                          context,
                          icon: Icons.person_rounded,
                          label: 'Perfil',
                          index: 3,
                          isExpanded: _isHoveringSidebar,
                          accentColor: accentColor,
                          isSelected: currentPageIndex == 3,
                          hoverColor: hoverColor,
                        ),
                      ],
                    ),
                  ),
      
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hoveredItemIndex = -1),
                      onExit: (_) => setState(() => _hoveredItemIndex = null),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 200),
                        scale: _hoveredItemIndex == -1 ? 1.05 : 1.0,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _hoveredItemIndex == -1 
                                ? hoverColor 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => showSettingsMenu(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: _isHoveringSidebar 
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.settings_rounded,
                                    color: _hoveredItemIndex == -1
                                        ? accentColor
                                        : accentColor.withValues(alpha: 0.8),
                                    size: _hoveredItemIndex == -1 ? 26 : 24,
                                  ),
                                  if (_isHoveringSidebar) ...[
                                    const SizedBox(width: 15),
                                    AnimatedOpacity(
                                      opacity: _isHoveringSidebar ? 1.0 : 0.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: Text(
                                        'Configuración',
                                        style: TextStyle(
                                          color: _hoveredItemIndex == -1
                                              ? accentColor
                                              : accentColor.withValues(alpha: 0.9),
                                          fontSize: _hoveredItemIndex == -1 ? 16 : 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      
          Expanded(
            child: ClipRRect(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.negro.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: <Widget>[
                    const MyWeekScreen(),
                    const TimetablePrincipalScreen(),
                    const NotificationsScreen(),
                    const ProfileMenuScreen(),
                  ][currentPageIndex],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    

    return isDesktop 
        ? _buildDesktopLayout(context, themeProvider)
        : _buildMobileLayout(context, themeProvider);
  }
}