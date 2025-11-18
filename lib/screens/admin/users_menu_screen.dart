import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/admin/admin.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class AdminUserMenuScreen extends StatelessWidget {
  const AdminUserMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminMenuSectionTitle('Requests to be Coach'),
                const SizedBox(height: 8),

                const CoachRequestsSection(),

                const SizedBox(height: 24),
                const AdminMenuSectionTitle('User Management'),
                const SizedBox(height: 8),

                Consumer<AdminStatsProvider>(
                  builder: (context, statsProvider, child) {
                    final totalUsers = statsProvider.totalUsers;
                    return ManagementCard(
                      icon: Pixel.users,
                      title: 'Our Users',
                      subtitle: '$totalUsers total users in the system',
                      buttonText: 'Manage Users',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminUsersScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                const AdminMenuSectionTitle('Reported Items'),
                const SizedBox(height: 8),

                ManagementCard(
                  icon: Pixel.flag,
                  title: 'Reported Items',
                  subtitle:
                      '0 items awaiting review', // TODO: connect to provider
                  buttonText: 'Manage Reported Items',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminReportedLogsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
