import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/auth/login_screen.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:focusflow/models/models.dart';
import '../core/main_navigation_controller.dart';

class UserLoadingScreen extends StatefulWidget {
  const UserLoadingScreen({super.key});

  @override
  State<UserLoadingScreen> createState() => _UserLoadingScreenState();
}

class _UserLoadingScreenState extends State<UserLoadingScreen> {
  bool _hasRetried = false;

  @override
  void initState() {
    super.initState();
    _attemptFetchUserData();
  }

  Future<void> _attemptFetchUserData() async {
    final authProvider = context.read<AuthProvider>();

    try {
      // First fetching attempt
      final success = await _fetchWithTimeout(authProvider);
      if (success && mounted) {
        _navigateToHome(authProvider);
        return;
      }

      // Retry if first failed - Second attempt
      if (!_hasRetried) {
        _hasRetried = true;
        if (mounted) {
          CustomSnackBar.show(
            context,
            message: "Retrying to fetch user data...",
            type: SnackBarType.info,
            position: SnackBarPosition.top,
            duration: const Duration(seconds: 2),
          );
        }

        final retrySuccess = await _fetchWithTimeout(authProvider);
        if (retrySuccess && mounted) {
          _navigateToHome(authProvider);
          return;
        }
      }
      
      // If both attempts fail, show error and navigate to login
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: "Poor connection. Returning to login screen.",
          type: SnackBarType.error,
          position: SnackBarPosition.top,
          duration: const Duration(seconds: 3),
        );

        await Future.delayed(const Duration(seconds: 3));

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context,
        message: "An error occurred. Please try again.",
        type: SnackBarType.error,
        position: SnackBarPosition.top,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  Future<bool> _fetchWithTimeout(AuthProvider authProvider) async {
    try {
      await authProvider.fetchUserData().timeout(
            const Duration(seconds: 4),
          );
      return authProvider.userModel != null;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }

  void _navigateToHome(AuthProvider authProvider) {
    if (!mounted) return;

    final roleString = authProvider.userModel?.role ?? 'user';
    final userRole = UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == roleString,
      orElse: () => UserRole.user,
    );

    CustomSnackBar.show(
      context,
      message: "Welcome back${authProvider.userModel?.username != null ? ', ${authProvider.userModel?.username}!' : '!'}",
      type: SnackBarType.success,
      position: SnackBarPosition.top,
      duration: const Duration(seconds: 2),
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainNavigationController(
          currentUserRole: userRole,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDarkMode ? theme.colorScheme.surface : Colors.white,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              "Loading user data...",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
