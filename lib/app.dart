import 'package:flutter/material.dart';
import 'package:focusflow/services/firebase_service.dart';
import 'package:focusflow/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await FirebaseService.initializeFirebase();
    setState(() => _initialized = true);
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
            return const Scaffold(
              body: Center(child: Text("Welcome!")),
            );
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
