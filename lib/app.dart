import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:focusflow/services/services.dart';
import 'package:focusflow/screens/auth/login_screen.dart';
import 'package:focusflow/theme/app_theme.dart';

import 'package:focusflow/screens/main_navigation_controller.dart';
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _initialized = false;
  bool _isDarkMode = true; // Default to dark mode

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await FirebaseService.initializeFirebase();
    setState(() => _initialized = true);
  }

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF222428),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFFBFFB4F)),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FocusFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF222428),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFBFFB4F)),
              ),
            );
          }

          if (snapshot.hasData) {
            UserRole determinedRole = UserRole.user;
            return MainNavigationController(
              currentUserRole: determinedRole,
              isDarkMode: _isDarkMode,
              onToggleTheme: _toggleTheme, // Pass the callback
            );
          } else {
            return LoginScreen(
              onToggleTheme: _toggleTheme, // Pass callback to LoginScreen
              isDarkMode: _isDarkMode,
            );
          }
        },
      ),
    );
  }
}
