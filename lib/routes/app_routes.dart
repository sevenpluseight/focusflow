import 'package:flutter/material.dart';
import 'package:focusflow/models/user_role.dart';
import 'package:focusflow/screens/auth/auth.dart';
import 'package:focusflow/screens/core/main_navigation_controller.dart';
import 'package:focusflow/screens/splash/splash_screen.dart';
import 'package:focusflow/screens/user/distraction_log_screen.dart';
import 'package:focusflow/screens/user/mood_tracker_screen.dart';

class CoachUserDistractionLogScreenArgs {
  final String userId;
  final String username;

  CoachUserDistractionLogScreenArgs({required this.userId, required this.username});
}

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String moodTracker = '/mood-tracker';
  static const String distractionLog = '/distraction-log';
  static const String coachUserDistractionLog = '/coach-user-distraction-log';

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
      case moodTracker:
        final sessionId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => MoodTrackerScreen(sessionId: sessionId),
        );
      case distractionLog:
        return MaterialPageRoute(builder: (_) => const DistractionLogScreen());
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
