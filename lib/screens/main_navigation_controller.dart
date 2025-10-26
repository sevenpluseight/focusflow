import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';

import 'placeholder_pages.dart';
import 'coach/coach_home_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'user/user_home_screen.dart';
import '../screens/auth/auth.dart';

// Define user roles
enum UserRole { user, coach, admin }

class MainNavigationController extends StatefulWidget {
  final UserRole currentUserRole;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const MainNavigationController({
    Key? key,
    required this.currentUserRole,
    required this.isDarkMode,
    required this.onToggleTheme,
  }) : super(key: key);

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

  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_authListener);

    _setupNavigationForRole(widget.currentUserRole);
  }

  void _authListener() {
    // If user logs out, navigate to login immediately
    if (!_authProvider.isLoggedIn && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
        (route) => false,
      );
    }
  }

  void _setupNavigationForRole(UserRole role) {
    switch (role) {
      case UserRole.user:
        _pageOptions = [
          const UserHomeScreen(),
          const PlaceholderPage(title: 'User Reports'),
          const PlaceholderPage(title: 'User Timer'),
          const PlaceholderPage(title: 'Coaches'),
          const PlaceholderPage(title: 'Profile'),
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
          const CoachHomeScreen(),
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
          const AdminDashboardScreen(),
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

  void _handleItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onTapDown(int index) {
    setState(() {
      _pressedIndex = index;
    });
  }

  void _onTapUpOrCancel(int index) {
    if (mounted && _pressedIndex == index) {
      setState(() {
        _pressedIndex = null;
      });
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_authListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF222428) : Colors.grey[100],
      appBar: AppBar(
        title: Text(_labels[_selectedIndex]),
        backgroundColor: isDarkMode ? const Color(0xFF2C2F33) : Colors.green,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          if (widget.currentUserRole == UserRole.user)
            IconButton(
              icon: const Icon(Pixel.notification, color: Colors.white, size: 28),
              onPressed: () {
                /* TODO: Navigate to Notifications */
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              _authProvider.clearError();
              await _authProvider.signOut();
              // Navigation handled by _authListener
            },
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
          final Color color =
              isActive ? const Color(0xFFBFFB4F) : const Color(0xFFD0D0D0);
          final double scaleFactor = isPressed ? 0.8 : (isActive ? 1.25 : 0.9);
          final double iconSize = isPressed ? 22 : (isActive ? 28 : 22);

          return GestureDetector(
            onTapDown: (_) => _onTapDown(index),
            onTapUp: (_) {
              _handleItemTap(index);
              _onTapUpOrCancel(index);
            },
            onTapCancel: () => _onTapUpOrCancel(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: MediaQuery.of(context).size.width / _iconList.length,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: scaleFactor,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    child: Icon(_iconList[index], size: iconSize, color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        activeIndex: _selectedIndex,
        onTap: (index) {}, // handled by GestureDetector
        backgroundColor: isDarkMode ? const Color(0xFF2C2F33) : Colors.green,
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.smoothEdge,
        height: 65,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
      ),
    );
  }
}
