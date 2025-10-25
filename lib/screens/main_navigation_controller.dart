// lib/screens/main_navigation_controller.dart
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

// Import pages
import 'placeholder_pages.dart';
import 'coach/coach_home_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'user/user_home_screen.dart';

// Define user roles
enum UserRole { user, coach, admin }

class MainNavigationController extends StatefulWidget {
  final UserRole currentUserRole;
  const MainNavigationController({Key? key, required this.currentUserRole}) : super(key: key);

  @override
  State<MainNavigationController> createState() => _MainNavigationControllerState();
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

  // UPDATED function with your chosen icons
  void _setupNavigationForRole(UserRole role) {
    switch (role) {
      case UserRole.user:
        _pageOptions = const [
          UserHomeScreen(),
          PlaceholderPage(title: 'User Reports'),
          PlaceholderPage(title: 'User Timer'),
          PlaceholderPage(title: 'Coach'), // Updated title slightly
          PlaceholderPage(title: 'User Profile'),
        ];
        _iconList = const [
          Pixel.home,        
          Pixel.chartmultiple,    
          Pixel.clock,      
          Pixel.contactmultiple,      
          Pixel.user,        
        ];
        _labels = const ['Home', 'Reports', 'Timer', 'Coaches', 'Profile']; // Match icons
        break;
      case UserRole.coach:
        _pageOptions = const [
          CoachHomeScreen(),
          PlaceholderPage(title: 'Coach Home'),
          PlaceholderPage(title: 'Coach User Mgt'),
          PlaceholderPage(title: 'Coach Challenge'),
          PlaceholderPage(title: 'Coach Reports'),
          PlaceholderPage(title: 'Coach Profile'),
        ];
        _iconList = const [
          Pixel.home,             // Home
          Pixel.users,  // User (Changed from users)
          Pixel.plus,             // Challenge (Changed from trophy)
          Pixel.chartmultiple,        // Reports (Changed from chart)
          Pixel.user,             // Profile
        ];
        _labels = const ['Home', 'Users', 'Challenge', 'Reports', 'Profile']; // Match icons
        break;
      case UserRole.admin:
        _pageOptions = const [
          AdminDashboardScreen(),
          PlaceholderPage(title: 'Admin Dashboard'),
          PlaceholderPage(title: 'Admin User Mgt'),
          PlaceholderPage(title: 'Admin Events'),
          PlaceholderPage(title: 'Admin Notifications'),
          PlaceholderPage(title: 'Admin Reports'),
        ];
        _iconList = const [
          Pixel.dashbaord,        // Dashboard (Changed from grid)
          Pixel.users,        // Users (Changed from users)
          Pixel.frameadd,    // Events (Changed from calendar)
          Pixel.notification,        // Notifications (Changed from notification/bell)
          Pixel.chartmultiple,   // Reports (Changed from chart)
        ];
        _labels = const ['Dashboard', 'Users', 'Events', 'Notify', 'Reports']; // Match icons
        break;
    }
  }

  void _handleItemTap(int index) {
    setState(() { _selectedIndex = index; });
  }
  void _onTapDown(int index) {
    setState(() { _pressedIndex = index; });
  }
  void _onTapUpOrCancel(int index) {
     if (mounted && _pressedIndex == index) {
       setState(() { _pressedIndex = null; });
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( index: _selectedIndex, children: _pageOptions, ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          final bool isPressed = _pressedIndex == index;
          final Color color = isActive ? const Color(0xFFBFFB4F) : const Color(0xFFD0D0D0);
          final double scaleFactor = isPressed ? 0.8 : (isActive ? 1.25 : 0.9);
          final double iconSize = isPressed ? 22 : (isActive ? 28 : 22);

          return GestureDetector(
            onTapDown: (_) => _onTapDown(index),
            onTapUp: (_) { _handleItemTap(index); _onTapUpOrCancel(index); },
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
                    child: Icon( _iconList[index], size: iconSize, color: color, ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        activeIndex: _selectedIndex,
        onTap: (index) {}, // Handled by GestureDetector
        backgroundColor: const Color(0xFF2C2F33),
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.smoothEdge,
        height: 65,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
      ),
    );
  }
}