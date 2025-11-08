
import 'package:flutter/material.dart';
import 'package:focusflow/models/user_role.dart';
import 'package:focusflow/screens/auth/login_screen.dart';
import 'package:focusflow/screens/auth/signup_screen.dart';
import 'package:focusflow/screens/core/main_navigation_controller.dart';
import 'package:focusflow/screens/splash/splash_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case home:
        final userRole = settings.arguments as UserRole? ?? UserRole.user;
        return MaterialPageRoute(
          builder: (_) => MainNavigationController(currentUserRole: userRole),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
