import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print("🚀 Starting app initialization...");
  await dotenv.load(fileName: ".env");
  print("✅ .env file loaded successfully.");

  print("⚙️ Initializing Firebase...");
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully!");
  } catch (e, stack) {
    print("❌ Firebase initialization failed: $e");
    print("🔍 Stack trace: $stack");
  }

  print("🟢 Launching app...");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FirebaseGeminiDebug(),
    );
  }
}

class FirebaseGeminiDebug extends StatefulWidget {
  const FirebaseGeminiDebug({super.key});

  @override
  State<FirebaseGeminiDebug> createState() => _FirebaseGeminiDebugState();
}

class _FirebaseGeminiDebugState extends State<FirebaseGeminiDebug> {
  String _firebaseStatus = "🔄 Checking Firebase...";
  String _geminiStatus = "⏳ Waiting for Firebase to complete...";

  @override
  void initState() {
    super.initState();
    _runChecks();
  }

  Future<void> _runChecks() async {
    await _checkFirebase();
    await _testGeminiAPI();
  }

  Future<void> _checkFirebase() async {
    print("⚙️ Verifying Firebase connection...");
    try {
      final app = Firebase.apps.isNotEmpty ? Firebase.apps.first : null;

      if (app == null) {
        setState(() => _firebaseStatus = "❌ Firebase app not found!");
        print("❌ Firebase app not found!");
        return;
      }

      print("✅ Firebase app detected: ${app.name}");
      print("📦 Firebase options:");
      print("  - Project ID: ${app.options.projectId}");
      print("  - App ID: ${app.options.appId}");
      print("  - API Key: ${app.options.apiKey}");
      print("  - Messaging Sender ID: ${app.options.messagingSenderId}");
      print("  - Storage Bucket: ${app.options.storageBucket}");

      setState(() => _firebaseStatus = "✅ Firebase initialized successfully!");
    } catch (e, stack) {
      setState(() => _firebaseStatus = "❌ Firebase initialization failed: $e");
      print("❌ Firebase initialization error: $e");
      print("🔍 Stack trace: $stack");
    }
  }

  Future<void> _testGeminiAPI() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      setState(() => _geminiStatus = "❌ Missing GEMINI_API_KEY in .env file");
      print(_geminiStatus);
      return;
    }

    setState(() => _geminiStatus = "🔍 Testing Gemini 2.0 Flash...");
    print("⚙️ Testing Gemini model (gemini-2.0-flash)...");

    final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
    const prompt = "Say hello from Gemini 2.0 Flash!";

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final result = response.text ?? "⚠️ No response from Gemini.";
      setState(() => _geminiStatus = "✅ Gemini 2.0 Flash response:\n$result");
      print("✅ Gemini response: $result");
    } catch (e, stack) {
      setState(() => _geminiStatus = "❌ Error connecting to Gemini: $e");
      print("❌ Gemini connection error: $e");
      print("🔍 Stack trace: $stack");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase & Gemini Debug")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _firebaseStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _geminiStatus,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
