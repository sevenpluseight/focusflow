import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/screens/coach/coach.dart';
import 'package:focusflow/screens/coach/coach.dart';

import '../common/placeholder_pages.dart';
import '../coach/coach_home_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../user/user_home_screen.dart';
import '../user/user_profile_screen.dart';
import '../auth/auth.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';

class MainNavigationController extends StatefulWidget {
  final UserRole currentUserRole;

  const MainNavigationController({super.key, required this.currentUserRole});

  @override
  State<MainNavigationController> createState() =>
      _MainNavigationControllerState();
}

class _MainNavigationControllerState extends State<MainNavigationController> {
  int _selectedIndex = 0;

  late List<Widget> _pageOptions;
  late List<IconData> _iconList;
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    _setupNavigationForRole(widget.currentUserRole);
  }

  void _setupNavigationForRole(UserRole role) {
    switch (role) {
      // User
      case UserRole.user:
        _pageOptions = [
          UserHomeScreen(),
          PlaceholderPage(title: 'User Reports'),
          PlaceholderPage(title: 'User Timer'),
          PlaceholderPage(title: 'Coaches'),
          UserProfileScreen(),
        ];
        _iconList = const [
          Pixel.home,
          Pixel.chartmultiple,
          Pixel.clock,
          Pixel.contactmultiple,
          Pixel.user,
        ];
        _labels = const ['Home', 'Reports', 'Timer', 'Coaches', 'Profile'];
        break;

      // Coach
      case UserRole.coach:
        _pageOptions = const [
          CoachHomeScreen(),
          CoachUserListScreen(),
          CoachChallengeScreen(),
          PlaceholderPage(title: 'Reports'),
          PlaceholderPage(title: 'Profile'),
        ];
        _iconList = const [
          Pixel.home,
          Pixel.users,
          Pixel.plus,
          Pixel.chartmultiple,
          Pixel.user,
        ];
        _labels = const ['Home', 'Users', 'Challenge', 'Reports', 'Profile'];
        break;

      // Admin
      case UserRole.admin:
        _pageOptions = const [
          AdminDashboardScreen(),
          PlaceholderPage(title: 'Users'),
          PlaceholderPage(title: 'Events'),
          PlaceholderPage(title: 'Notifications'),
          PlaceholderPage(title: 'Reports'),
        ];
        _iconList = const [
          Pixel.dashbaord,
          Pixel.users,
          Pixel.frameadd,
          Pixel.edit,
          Pixel.chartmultiple,
        ];
        _labels = const ['Dashboard', 'Users', 'Events', 'Notify', 'Reports'];
        break;
    }
  }

  void _handleItemTap(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
  }

  Future<void> _showLogoutConfirmationDialog() async {
    final authProvider = context.read<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: theme.scaffoldBackgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Confirm Logout',
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54, fontSize: 16),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 16),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: Text(
                'Logout',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true && mounted) {
      try {
        await authProvider.signOut();
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Logout failed: $e"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Lighter color for top & bottom bars
    final Color barColor = isDark ? const Color(0xFF3A3D42) : Color(0xFFE8F5E9);
    // Darker color for screen background
    final Color backgroundColor = isDark ? const Color(0xFF2C2F33) : Colors.grey[100]!;

    final Color activeColor =  isDark ? AppTheme.primaryColor : const Color(0xFF007A5E);
    final Color inactiveColor = isDark ? Colors.white70 : Colors.grey.shade700;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: barColor,
        elevation: 0,
        title: Text(
          _labels[_selectedIndex],
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 20),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              isDark ? Pixel.sunalt : Pixel.moon,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          if (widget.currentUserRole == UserRole.user ||
              widget.currentUserRole == UserRole.coach)
            IconButton(
              tooltip: 'Notifications',
              icon: Icon(
                Pixel.notification,
                size: 28,
                color: isDark ? Colors.white : Colors.black87,
              ),
              onPressed: () {},
            ),
          IconButton(
            tooltip: 'Logout',
            icon: Icon(
              Pixel.logout,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: _showLogoutConfirmationDialog,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pageOptions,
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          return AnimatedNavBarItem(
            index: index,
            iconData: _iconList[index],
            label: _labels[index],
            isActive: isActive,
            onTap: () => _handleItemTap(index),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          );
        },
        activeIndex: _selectedIndex,
        onTap: _handleItemTap,
        backgroundColor: barColor,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.sharpEdge,
        height: 65,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        elevation: 0,
      ),
    );
  }
}
