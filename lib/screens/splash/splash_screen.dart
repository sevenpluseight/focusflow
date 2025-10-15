import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../firebase_options.dart';
import '../auth/login_screen.dart';

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

    // 🌈 Fade + Scale Animation
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
      print("✅ Firebase initialized successfully!");

      setState(() => _statusText = "🤖 Connecting to Gemini...");
      await _testGeminiAPI();

      // Wait briefly to let animation complete
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      print("❌ Initialization failed: $e");
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
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      setState(() => _statusText = "❌ Missing GEMINI_API_KEY in .env file");
      print(_statusText);
      throw Exception("Missing GEMINI_API_KEY in .env");
    }

    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    const prompt = "Say hello from FocusFlow startup check!";

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text ?? "⚠️ No response from Gemini.";
      print("✅ Gemini connected successfully: $text");
      setState(() => _statusText = "✅ Gemini connected!");
    } catch (e) {
      print("❌ Gemini connection failed: $e");
      throw Exception("Gemini connection failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222428),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SvgPicture.asset(
                  'assets/icons/focusflow_icon.svg',
                  width: 140,
                  height: 140,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              _statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
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
