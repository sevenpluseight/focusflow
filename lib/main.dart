import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/app.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/services/firebase_service.dart';
import 'package:focusflow/theme/app_theme.dart';
import 'package:focusflow/screens/auth/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FocusFlow',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/login',
            routes: {
              '/': (context) => const App(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
