import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusflow/screens/auth/login_screen.dart';
import 'package:focusflow/screens/core/main_navigation_controller.dart';
import 'package:focusflow/services/user_service.dart';
import 'package:focusflow/models/models.dart';

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
          return FutureBuilder<UserModel?>(
            key: ValueKey(snapshot.data!.uid),
            future: UserService().getUser(snapshot.data!.uid),
            builder: (context, userModelSnapshot) {
              if (userModelSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF222428),
                  body: Center(
                    child: CircularProgressIndicator(color: Color(0xFFBFFB4F)),
                  ),
                );
              }

              if (userModelSnapshot.hasError) {
                // Handle error, maybe show an error screen
                return const Scaffold(
                  body: Center(
                    child: Text('Error fetching user data'),
                  ),
                );
              }

              final UserModel? userModel = userModelSnapshot.data;
              UserRole userRole = UserRole.user; // Default role

              if (userModel != null) {
                final roleString = userModel.role.toLowerCase();
                userRole = UserRole.values.firstWhere(
                  (e) => e.toString().split('.').last == roleString,
                  orElse: () => UserRole.user,
                );
              }

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
