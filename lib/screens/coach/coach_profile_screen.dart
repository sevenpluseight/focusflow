import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/auth/auth.dart';
import 'package:focusflow/screens/core/main_navigation_controller.dart';
import 'package:focusflow/widgets/widgets.dart';
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
        builder: (_) =>
            const MainNavigationController(currentUserRole: UserRole.user),
      ),
    );
  }

  // --- Logic for "Log Out" ---
  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const ConfirmationDialog(
          title: 'Confirm Logout',
          contentText: 'Are you sure you want to log out?',
          confirmText: 'Logout',
        );
      },
    );

    if (confirmLogout == true && context.mounted) {
      await authProvider.signOut(context);
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
            StyledCard(
              padding: const EdgeInsets.all(20),
              child: Text(
                user?.username ?? 'Coach',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Switch to User Mode Button
            PrimaryButton(
              onPressed: () => _switchToUserMode(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Pixel.repeat),
                  SizedBox(width: 8),
                  Text('Switch to User Mode'),
                ],
              ),
            ),
            const SizedBox(height: 32), // Gap before settings

            // --- Settings ---
            Text(
              "Settings",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              onPressed: () => context.read<ThemeProvider>().toggleTheme(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(theme.brightness == Brightness.dark ? Pixel.sunalt : Pixel.moon),
                  const SizedBox(width: 8),
                  const Text('Theme Preferences'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SecondaryButton(
              onPressed: () => _showLogoutConfirmation(context),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Pixel.logout),
                  SizedBox(width: 8),
                  Text('Log Out'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
