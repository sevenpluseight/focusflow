import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:focusflow/screens/coach/coach.dart';
import 'package:focusflow/screens/user/user.dart';
import 'package:focusflow/screens/admin/admin.dart';
import 'package:focusflow/screens/user/user_notification_screen.dart';
import 'package:focusflow/screens/coach/coach_notification_screen.dart'; // Added import
import 'package:focusflow/screens/user/user_timer_screen.dart'; // Added import
import '../auth/auth.dart';

import '../common/placeholder_pages.dart';
// import '../coach/coach_home_screen.dart';
// import '../admin/admin.dart';
// import '../user/user_home_screen.dart';
// import '../user/user_profile_screen.dart';
// import '../auth/auth.dart';
// import '../../theme/app_theme.dart';

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

    if (widget.currentUserRole == UserRole.admin) {
      context.read<AdminStatsProvider>().ensureInitialized();
      context.read<AdminUsersProvider>().ensureInitialized();
    }
  }

  void _setupNavigationForRole(UserRole role) {
    switch (role) {
      case UserRole.user:
        _pageOptions = [
          UserHomeScreen(),
          PlaceholderPage(title: 'User Reports'),
          UserTimeScreen(),
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

      case UserRole.coach:
        _pageOptions = const [
          CoachHomeScreen(),
          CoachUserListScreen(),
          CoachChallengeScreen(),
          CoachReportSummaryScreen(),
          CoachProfileScreen(),
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
          AdminUserMenuScreen(),
          AdminChallengeMenuScreen(),
          AdminNotificationViewScreen(),
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

    if (confirmLogout == true && mounted) {
      try {
        await authProvider.signOut(context);
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
    final navBarColor = isDark
        ? const Color(0xFF2C2F33)
        : theme.bottomNavigationBarTheme.backgroundColor ?? Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: navBarColor,
        elevation: theme.appBarTheme.elevation,
        title: Text(
          _labels[_selectedIndex],
          style: theme.appBarTheme.titleTextStyle,
        ),
        iconTheme: theme.appBarTheme.iconTheme,
        automaticallyImplyLeading: false,
        actions: [
          if (widget.currentUserRole == UserRole.user ||
              widget.currentUserRole == UserRole.coach)
            IconButton(
              tooltip: 'Notifications',
              icon: Icon(
                Pixel.notification,
                size: 28,
                color: theme.appBarTheme.iconTheme?.color,
              ),
              onPressed: () {
                if (widget.currentUserRole == UserRole.user) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserNotificationScreen(),
                    ),
                  );
                } else if (widget.currentUserRole == UserRole.coach) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoachNotificationScreen(),
                    ),
                  );
                }
              },
            ),
          IconButton(
            tooltip: 'Logout',
            icon: Icon(Pixel.logout, color: theme.appBarTheme.iconTheme?.color),
            onPressed: _showLogoutConfirmationDialog,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pageOptions),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount: _iconList.length,
        tabBuilder: (int index, bool isActive) {
          return AnimatedNavBarItem(
            index: index,
            iconData: _iconList[index],
            label: _labels[index],
            isActive: isActive,
            onTap: () => _handleItemTap(index),
            activeColor: theme.colorScheme.primary,
            inactiveColor:
                theme.bottomNavigationBarTheme.unselectedItemColor ??
                Colors.grey,
          );
        },
        activeIndex: _selectedIndex,
        onTap: _handleItemTap,
        backgroundColor: navBarColor,
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
