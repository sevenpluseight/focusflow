import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';

import 'placeholder_pages.dart';
import 'coach/coach_home_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'user/user_home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/animated_nav_bar_item.dart';
import '../theme/app_theme.dart';

// Define user roles
enum UserRole { user, coach, admin }

class MainNavigationController extends StatefulWidget {
  final UserRole currentUserRole;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainNavigationController({
    super.key,
    required this.currentUserRole,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<MainNavigationController> createState() =>
      _MainNavigationControllerState();
}

class _MainNavigationControllerState extends State<MainNavigationController> {
  int _selectedIndex = 0;
  int? _pressedIndex;

  late List<Widget> _pageOptions;
  late List<IconData> _iconList;
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    _setupNavigationForRole(widget.currentUserRole);
  }

  // Setup navigation based on user role
  void _setupNavigationForRole(UserRole role) {
    switch (role) {
      case UserRole.user:
        _pageOptions = const [
          UserHomeScreen(),
          PlaceholderPage(title: 'User Reports'),
          PlaceholderPage(title: 'User Timer'),
          PlaceholderPage(title: 'Coaches'),
          PlaceholderPage(title: 'Profile'),
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

      case UserRole.coach:
        _pageOptions = const [
          CoachHomeScreen(),
          PlaceholderPage(title: 'Coach Users'),
          PlaceholderPage(title: 'Challenge'),
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
          Pixel.notification,
          Pixel.chartmultiple,
        ];
        _labels = const ['Dashboard', 'Users', 'Events', 'Notify', 'Reports'];
        break;
    }
  }

  // Tab handling
  void _handleItemTap(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
  }

  void _onTapDown(int index) {
    if (!mounted) return;
    setState(() => _pressedIndex = index);
  }

  void _onTapUpOrCancel(int index) {
    if (mounted && _pressedIndex == index) {
      setState(() => _pressedIndex = null);
    }
  }

  // Logout confirmation dialog (✅ fixed: only one click needed)
  Future<void> _showLogoutConfirmationDialog() async {
    final authProvider = context.read<AuthProvider>();

    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        final isDark = theme.brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2C2F33) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Confirm Logout',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          content: Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style:
                    TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            TextButton(
              child: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true && mounted) {
      try {
        await authProvider.signOut();
        // Navigate directly — no second click
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(
              settings: const RouteSettings(name: '/login'),
              builder: (_) => LoginScreen(
                isDarkMode: widget.isDarkMode,
                onToggleTheme: widget.onToggleTheme,
              ),
            ),
            (route) => false,
          );
        }
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ??
            (isDark ? const Color(0xFF2C2F33) : Colors.white),
        elevation: 0,
        title: Text(
          _labels[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        actions: [
          if (widget.currentUserRole == UserRole.user ||
              widget.currentUserRole == UserRole.admin)
            IconButton(
              tooltip: 'Notifications',
              icon: Icon(
                widget.currentUserRole == UserRole.admin
                    ? Pixel.edit
                    : Pixel.notification,
                size: 28,
                color: Colors.white,
              ),
              onPressed: () {
                debugPrint(
                    '${widget.currentUserRole.name} Notification Icon Tapped');
              },
            ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, color: Colors.white),
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
          final bool isPressed = _pressedIndex == index;
          return AnimatedNavBarItem(
            index: index,
            iconData: _iconList[index],
            label: _labels[index],
            isActive: isActive,
            isPressed: isPressed,
            activeColor: AppTheme.primaryColor,
            inactiveColor:
                isDark ? const Color(0xFFD0D0D0) : Colors.grey.shade600,
            onTapDown: () => _onTapDown(index),
            onTapUp: () {
              _handleItemTap(index);
              _onTapUpOrCancel(index);
            },
            onTapCancel: () => _onTapUpOrCancel(index),
          );
        },
        activeIndex: _selectedIndex,
        onTap: (_) {},
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ??
            (isDark ? const Color(0xFF2C2F33) : Colors.white),
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.smoothEdge,
        height: 65,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
      ),
    );
  }
}
