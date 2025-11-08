import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

import '../../firebase_options.dart';
import '../auth/auth.dart';
import '../core/main_navigation_controller.dart';
import '../../services/services.dart';
import '../../models/models.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String _statusText = "🚀 Starting app...";

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _statusText = "⚙️ Initializing Firebase...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      User? user = FirebaseAuth.instance.currentUser;

      setState(() => _statusText = "🤖 Connecting to Gemini...");
      await _testGeminiAPI(); // Keep Gemini check

      Widget nextScreen;

      if (user == null) {
        // User is LOGGED OUT
        setState(() => _statusText = "🔒 Redirecting to Login...");
        nextScreen = const LoginScreen();
      } else {
        // User is LOGGED IN
        setState(() => _statusText = "🔓 User authenticated. Checking role...");

        final UserService userService = UserService();
        final UserModel? userModel = await userService.getUser(user.uid);

        UserRole userRole = UserRole.user; // default

        if (userModel != null) {
          final roleString = userModel.role.toLowerCase();
          switch (roleString) {
            case 'user':
              userRole = UserRole.user;
              break;
            case 'coach':
              userRole = UserRole.coach;
              break;
            case 'admin':
              userRole = UserRole.admin;
              break;
            default:
              userRole = UserRole.user;
          }
        }

        setState(() => _statusText = "🔑 Role determined: $userRole. Loading app...");
        nextScreen = MainNavigationController(currentUserRole: userRole);
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, _, _) => nextScreen,
            transitionsBuilder: (_, animation, _, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusText = "❌ Initialization failed: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Initialization failed: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _testGeminiAPI() async {
    try {
      final result = await GeminiService.testConnection();
      if (result.startsWith("✅")) {
        setState(() => _statusText = "✅ Gemini connected!");
      } else {
        setState(() => _statusText = "⚠️ Gemini connection failed (continuing...)");
      }
      debugPrint(result);
    } catch (e) {
      setState(() => _statusText = "⚠️ Gemini connection failed (continuing...)");
      debugPrint("⚠️ Gemini connection failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF222428),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 3,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SvgPicture.asset(
                        'assets/icons/svg/focusflow_icon.svg',
                        width: size.width * 0.35,
                        height: size.width * 0.35,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "FocusFlow",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}