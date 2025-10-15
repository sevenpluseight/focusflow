import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("🚀 Starting app initialization...");
  await dotenv.load(fileName: ".env");
  print("✅ .env file loaded successfully.");

  // ⚙️ Don't initialize Firebase here anymore
  // We'll do it inside SplashScreen for better UX.

  print("🟢 Launching app...");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
