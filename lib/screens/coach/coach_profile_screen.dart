import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/auth/auth.dart';
import 'package:focusflow/screens/core/main_navigation_controller.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({Key? key}) : super(key: key);

  // --- Logic for "Switch to User Mode" ---
  void _switchToUserMode(BuildContext context) {
    // Reload the main navigation controller, forcing it into 'UserRole.user'
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationController(
          currentUserRole: UserRole.user,
        ),
      ),
    );
  }

  // --- Logic for "Log Out" ---
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(
                'Logout',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true && context.mounted) {
      await authProvider.signOut();
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<UserProvider>().user;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Username Card
            _buildProfileCard(
              theme: theme,
              text: user?.username ?? 'Coach',
              isHeader: true,
            ),
            const SizedBox(height: 16),

            // Switch to User Mode Button
              ElevatedButton.icon(
              icon: const Icon(Pixel.repeat),
              label: const Text('Switch to User Mode'),
              onPressed: () => _switchToUserMode(context),
              style: ElevatedButton.styleFrom(
                // Using a distinct color to make it stand out
                backgroundColor: Colors.green, 
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // --- Settings ---
            const Text(
              "Settings",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildProfileButton(
              theme: theme,
              icon: theme.brightness == Brightness.dark ? Pixel.sunalt : Pixel.moon,
              label: 'Theme Preferences',
              onTap: () => context.read<ThemeProvider>().toggleTheme(),
            ),
            const SizedBox(height: 12),
            _buildProfileButton(
              theme: theme,
              icon: Pixel.logout,
              label: 'Log Out',
              onTap: () => _showLogoutConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for username card
  Widget _buildProfileCard({
    required ThemeData theme,
    required String text,
    bool isHeader = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 20 : 16,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Helper for the buttons
  Widget _buildProfileButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 28,
              color: theme.colorScheme.onSurface,
              ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (label != 'Theme Preferences' && label != 'Log Out')
              const Icon(Pixel.chevronright, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}