// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'screens/splash/splash_screen.dart';


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   print("🚀 Starting app initialization...");
//   await dotenv.load(fileName: ".env");
//   print("✅ .env file loaded successfully.");

//   // ⚙️ Don't initialize Firebase here anymore
//   // We'll do it inside SplashScreen for better UX.

//   print("🟢 Launching app...");
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: SplashScreen(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:focusflow/app.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const App());
// }

// import 'package:flutter/material.dart';
// import 'package:focusflow/theme/app_theme.dart';
// import 'package:focusflow/screens/auth/login_screen.dart';
// import 'package:focusflow/services/services.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const FocusFlowApp());
// }

// class FocusFlowApp extends StatelessWidget {
//   const FocusFlowApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: FirebaseService.initializeFirebase(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Show loading indicator while Firebase initializes
//           return const MaterialApp(
//             home: Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             ),
//           );
//         } else if (snapshot.hasError) {
//           // Show error message if Firebase fails
//           return MaterialApp(
//             home: Scaffold(
//               body: Center(
//                 child: Text('Firebase failed to initialize: ${snapshot.error}'),
//               ),
//             ),
//           );
//         } else {
//           return const AppWithTheme();
//         }
//       },
//     );
//   }
// }

// class AppWithTheme extends StatefulWidget {
//   const AppWithTheme({super.key});

//   @override
//   State<AppWithTheme> createState() => _AppWithThemeState();
// }

// class _AppWithThemeState extends State<AppWithTheme> {
//   bool _isDarkMode = true;

//   void _toggleTheme() {
//     setState(() {
//       _isDarkMode = !_isDarkMode;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'FocusFlow',
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
//       home: LoginScreen(
//         isDarkMode: _isDarkMode,
//         onToggleTheme: _toggleTheme,
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:focusflow/app.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const App());
// }

// import 'package:flutter/material.dart';
// import 'package:focusflow/theme/app_theme.dart';
// import 'package:focusflow/screens/auth/login_screen.dart';
// import 'package:focusflow/services/services.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const FocusFlowApp());
// }

// class FocusFlowApp extends StatelessWidget {
//   const FocusFlowApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: FirebaseService.initializeFirebase(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Show loading indicator while Firebase initializes
//           return const MaterialApp(
//             home: Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             ),
//           );
//         } else if (snapshot.hasError) {
//           // Show error message if Firebase fails
//           return MaterialApp(
//             home: Scaffold(
//               body: Center(
//                 child: Text('Firebase failed to initialize: ${snapshot.error}'),
//               ),
//             ),
//           );
//         } else {
//           return const AppWithTheme();
//         }
//       },
//     );
//   }
// }

// class AppWithTheme extends StatefulWidget {
//   const AppWithTheme({super.key});

//   @override
//   State<AppWithTheme> createState() => _AppWithThemeState();
// }

// class _AppWithThemeState extends State<AppWithTheme> {
//   bool _isDarkMode = true;

//   void _toggleTheme() {
//     setState(() {
//       _isDarkMode = !_isDarkMode;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'FocusFlow',
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
//       home: LoginScreen(
//         isDarkMode: _isDarkMode,
//         onToggleTheme: _toggleTheme,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/theme/app_theme.dart';
import 'package:focusflow/screens/auth/auth.dart';
import 'package:focusflow/services/services.dart';
import 'package:focusflow/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatefulWidget {
  const FocusFlowApp({super.key});

  @override
  State<FocusFlowApp> createState() => _FocusFlowAppState();
}

class _FocusFlowAppState extends State<FocusFlowApp> {
  bool _isDarkMode = true;
  late final Future<void> _firebaseInitFuture;

  @override
  void initState() {
    super.initState();
    _firebaseInitFuture = FirebaseService.initializeFirebase();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseInitFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a splash/loading screen while Firebase initializes
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Text(
                  "Firebase failed to initialize: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        } else {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthProvider()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'FocusFlow',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: LoginScreen(
                isDarkMode: _isDarkMode,
                onToggleTheme: _toggleTheme,
              ),
            ),
          );
        }
      },
    );
  }
}
