import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import '../../firebase_options.dart';
import '../auth/auth.dart';
import '../core/main_navigation_controller.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';

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

    // Delay initialization to after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<String> _connectToGemini({int retries = 3}) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        debugPrint("[SplashScreen] 🤖 Connecting to Gemini (attempt $attempt)...");
        setState(() => _statusText = "🤖 Connecting to Gemini (attempt $attempt)...");

        final result = await GeminiService.testConnection();
        debugPrint("[SplashScreen] Gemini response: $result");

        if (result.startsWith("✅")) {
          debugPrint("[SplashScreen] ✅ Gemini connected successfully!");
          return result;
        }
      } catch (e) {
        debugPrint("[SplashScreen] ❌ Gemini attempt $attempt failed: $e");
        if (attempt == retries) throw Exception("Failed to connect to Gemini after $retries attempts.");
        await Future.delayed(Duration(seconds: 2 * attempt));
      }
    }
    throw Exception("Gemini connection failed");
  }

  Future<void> _initializeApp() async {
    try {
      setState(() => _statusText = "⚙️ Initializing Firebase...");
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      // Connect to Gemini
      try {
        final geminiResult = await _connectToGemini();
        if (!mounted) return;
        setState(() => _statusText = geminiResult);
      } catch (geminiError) {
        debugPrint("[SplashScreen] ❌ Gemini connection failed: $geminiError");
        if (!mounted) return;
        setState(() => _statusText = "⚠️ Gemini connection failed (continuing...)");
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      Widget nextScreen;

      if (authProvider.isLoggedIn) {
        setState(() => _statusText = "🔓 User authenticated. Loading app...");

        // Fetch user after first frame to avoid notifyListeners during build
        await userProvider.fetchUser();

        final userModel = userProvider.user;
        UserRole userRole = UserRole.user;

        if (userModel != null) {
          final roleString = userModel.role.toLowerCase();
          userRole = UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == roleString,
            orElse: () => UserRole.user,
          );
        }

        nextScreen = MainNavigationController(currentUserRole: userRole);
      } else {
        setState(() => _statusText = "🔒 Redirecting to Login...");
        debugPrint("[SplashScreen] 🔒 Redirecting to Login...");
        nextScreen = const LoginScreen();
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusText = "❌ Initialization failed: $e");
      debugPrint("[SplashScreen] ❌ Initialization failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Initialization failed: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
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
