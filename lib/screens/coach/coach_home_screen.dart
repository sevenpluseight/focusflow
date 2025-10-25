import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

class CoachHomeScreen extends StatelessWidget {
  const CoachHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222428), // Dark charcoal background
      appBar: AppBar(
        title: const Text(
          'Coach Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF222428),
        elevation: 0,
        automaticallyImplyLeading: false, // No back button
        actions: [
          // Optional: Add notification icon if needed for coaches
          IconButton(
            icon: const Icon(Pixel.notification, color: Colors.white, size: 28),
            onPressed: () {
              /* TODO: Navigate to Coach Notifications if applicable */
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        // Allow scrolling
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Pending Requests Section (Figure 19) ---
            const Text(
              'Pending User Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO: Fetch and display pending requests here
                  Text(
                    'User 1 wants to connect...',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'User 2 wants to connect...',
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'View More >',
                      style: TextStyle(color: Color(0xFFBFFB4F)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- Quick Stats Section (Figure 19) ---
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO: Fetch and display actual stats
                  Text(
                    '• Total Users Coached: 5',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    '• Avg Focus Today: 3.2 Hrs',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    '• Ongoing Challenges: 2',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- AI Highlights Section (Figure 19) ---
            const Text(
              'AI Highlights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO: Fetch and display AI alerts
                  Text(
                    '• Alert: User 3 shows potential burnout risk.',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    '• Suggestion: Check in with User 5 about recent distraction patterns.',
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
