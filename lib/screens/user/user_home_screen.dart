import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/auth/auth.dart';

class UserHomeScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const UserHomeScreen({Key? key, required this.isDarkMode, required this.onToggleTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.username ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFF222428), 
      appBar: AppBar(
        title: const Text(
          'User Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2C2F33),
        elevation: 1,
        automaticallyImplyLeading: false, // No back button
        actions: [
          IconButton(
            icon: const Icon(Pixel.notification, color: Colors.white, size: 28),
            onPressed: () {
              /* TODO: Navigate to Notifications */
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              authProvider.clearError();
              await authProvider.signOut(); // wait until logout completes

              // Navigate directly to LoginScreen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    isDarkMode: isDarkMode,
                    onToggleTheme: onToggleTheme,
                  ),
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Greeting
              Text(
                'Good Morning, $username!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Productivity Tips box
              Container(/* ... Tip Box code ... */),
              const SizedBox(height: 40),
              // Circular Progress Chart placeholder
              Stack(/* ... Chart code ... */),
              const SizedBox(height: 20),
              // Progress text
              const Text(
                'Today\'s Progress: 75%',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
