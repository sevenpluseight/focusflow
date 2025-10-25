// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart'; // Import icons

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222428), // Dark charcoal background
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF222428),
        elevation: 0,
        automaticallyImplyLeading: false, // No back button
        // --- ADDED ACTIONS SECTION ---
        actions: [
          IconButton(
            icon: const Icon(Pixel.notification, color: Colors.white, size: 26), // Adjusted size slightly
            tooltip: 'View Reports/Alerts', // Optional: Tooltip
            onPressed: () {
              // TODO: Implement navigation to a screen for admin notifications/reports
              print('Admin Notification Icon Tapped');
              // Example: Navigator.push(...);
            },
          ),
          const SizedBox(width: 10), // Padding on the right
        ],
        // --- END ADDED ACTIONS SECTION ---
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildDashboardCard(
              title: 'System Stats',
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Total Users: 150', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                  Text('• Active Coaches: 12', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                  Text('• Daily Engagement: 65%', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDashboardCard(
              title: 'Focus Trends',
              content: Container(
                height: 150,
                alignment: Alignment.center,
                child: const Text(
                  '[Placeholder for Focus Trend Chart]',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDashboardCard(
              title: 'Common Distractions',
              content: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. Social Media (35%)', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                  Text('2. Environment Noise (22%)', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                  Text('3. Messaging Apps (18%)', style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent cards
  Widget _buildDashboardCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}