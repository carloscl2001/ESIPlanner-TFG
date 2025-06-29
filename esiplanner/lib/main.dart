import 'package:esiplanner/shared/app_colors.dart';
import 'package:esiplanner/services/background_nofication_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Añadido para el Timer

// Providers
import 'package:provider/provider.dart';
import '/providers/auth_provider.dart';
import '/providers/theme_provider.dart';

// Navigation menu
import 'features/login/login_screen.dart';
import 'features/register/register_screen.dart';
import 'shared/navigation_menu_bar.dart';

// Screens
import 'non_features/profile_menu_screen.dart';

// Screens of features
import 'features/timetable/timetable_principal/timetable_principal_logic.dart';
import 'features/edit_password/edit_password_screen.dart';
import 'features/view_profile/view_profile_screen.dart';
import 'features/selection_subjects/select_subjects_principal/select_subjects_principal_screen.dart';
import 'features/view_subjects/view_subjects_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa los datos de localización para español (ajusta a tu idioma y región)
  await initializeDateFormatting('es_ES', null); // O el locale que desees

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => TimetablePrincipalLogic(context)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final BackgroundNotificationService _notificationService = 
      BackgroundNotificationService();
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _startNotificationChecker();
  }

  Future<void> _initializeApp() async {
    // Cargar el tema guardado al iniciar la aplicación
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.loadTheme();

    // Cargar el estado de autenticación al iniciar la aplicación
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.loadAuthState();

    // Comprobar notificaciones solo si está autenticado
    if (authProvider.isAuthenticated) {
      await _notificationService.checkForNewNotifications(authProvider);
    }
  }

  void _startNotificationChecker() {
    // Comprobar cada 30 minutos (1800 segundos)
    _notificationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        await _notificationService.checkForNewNotifications(authProvider);
      }
    });
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // TEMA CLARO
      theme: ThemeData.light().copyWith(
        // Usar la fuente Inter para el tema claro
        scaffoldBackgroundColor: AppColors.azulClaro2,
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.azulUCA,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.blanco,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          labelStyle: GoogleFonts.inter(color: AppColors.azulUCA), // Usar Inter
          hintStyle: GoogleFonts.inter(color: AppColors.negro), // Usar Inter
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.azulUCA, width: 1.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.azulUCA, width: 2.0),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.inter( // Usar Inter
                color: AppColors.azulUCA,
                fontWeight: FontWeight.bold,
              );
            }
            return GoogleFonts.inter(color: Colors.grey); // Usar Inter
          }),
          backgroundColor: AppColors.blanco,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: AppColors.azulUCA,
            textStyle: GoogleFonts.inter( // Usar Inter
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.blanco,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.azulUCA,
          titleTextStyle: GoogleFonts.inter( // Usar Inter
            color: AppColors.blanco,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: AppColors.blanco),
        ),
      ),

      // TEMA OSCURO
      darkTheme: ThemeData.dark().copyWith(
        // Usar la fuente Inter para el tema oscuro
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.amarillo,
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.negro,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          labelStyle: GoogleFonts.inter(color: AppColors.blanco), // Usar Inter
          hintStyle: GoogleFonts.inter(color: AppColors.blanco), // Usar Inter
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.amarillo, width: 1.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.amarillo, width: 2.5),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.inter( // Usar Inter
                color: AppColors.amarillo,
                fontWeight: FontWeight.bold,
              );
            }
            return GoogleFonts.inter(color: Colors.grey); // Usar Inter
          }),
          backgroundColor: AppColors.negro,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            backgroundColor: AppColors.amarillo,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter( // Usar Inter
              fontSize: 18,
              color: AppColors.negro,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.negro,
          titleTextStyle: GoogleFonts.inter( // Usar Inter
            color: AppColors.blanco,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: AppColors.blanco),
        ),
      ),
      themeMode: themeProvider.themeMode, // Usa el tema actual del ThemeProvider
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return authProvider.isAuthenticated
                    ? const NavigationMenuBar()
                    : const LoginScreen();
              },
            ),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const NavigationMenuBar(),
        '/profileMenu': (context) => const ProfileMenuScreen(),
        '/viewProfile': (context) => const ViewProfileScreen(),
        '/editPassWord': (context) => const EditPasswordScreen(),
        '/viewSubjects': (context) => const ViewSubjectsScreen(),
        '/selectionSubjects': (context) => const SubjectSelectionScreen(),
      },
    );
  }
}