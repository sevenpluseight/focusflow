import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

@override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final username = authProvider.username ?? "User"; // Get username

    return Container( // Use a Container if you need specific background/padding
      color: const Color(0xFF222428), 
      child: Center( 
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Greeting
              Text(
                'Good Morning, $username!', 
                textAlign: TextAlign.center, 
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // Productivity Tips box Placeholder
              Container(
                 width: double.infinity,
                 padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                 decoration: BoxDecoration(
                   color: Colors.white.withAlpha((255 * 0.8).toInt()),
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: const Text(
                   'Productivity Tip: Placeholder!', // TODO: Load dynamic tips
                   style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 14),
                   textAlign: TextAlign.center,
                 ),
              ),
              const SizedBox(height: 40),
              // Circular Progress Chart placeholder
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: 0.75, // TODO: Replace with actual progress
                      strokeWidth: 12,
                      backgroundColor: Colors.white.withAlpha((255 * 0.8).toInt()),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFBFFB4F)),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                   const Text(
                    '3 / 4 Hrs', // TODO: Show actual progress dynamically
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Today\'s Progress: 75%', // TODO: Make dynamic
                 textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}