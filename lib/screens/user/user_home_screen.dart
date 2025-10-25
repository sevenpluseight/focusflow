import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // NOTE: This Scaffold is only for the AppBar.
    // The BottomNavigationBar is handled by MainNavigationController.
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
              const Text(
                'Good Morning, [Username]!', // TODO: Fetch username
                style: TextStyle(
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
