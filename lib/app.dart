import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/screens/auth/login_screen.dart';
import 'package:focusflow/screens/main_navigation_controller.dart';
import 'package:focusflow/services/user_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
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
          return FutureBuilder<UserRole>(
            key: ValueKey(snapshot.data!.uid),
            future: UserService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF222428),
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFFBFFB4F)),
                  ),
                );
              }

              if (roleSnapshot.hasError) {
                // Handle error, maybe show an error screen
                return const Scaffold(
                  body: Center(
                    child: Text('Error fetching user role'),
                  ),
                );
              }

              final userRole = roleSnapshot.data ?? UserRole.user;
              return MainNavigationController(
                currentUserRole: userRole,
              );
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
