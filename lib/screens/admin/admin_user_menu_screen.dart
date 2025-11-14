import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/models/models.dart';
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
                // coach requests section
                _buildSectionTitle(context, 'Requests to be Coach'),
                const SizedBox(height: 8),
                _buildCoachRequestsCard(context),

                const SizedBox(height: 24),

                // user managment card
                _buildSectionTitle(context, 'User Management'),
                const SizedBox(height: 8),
                Consumer<AdminStatsProvider>(
                  builder: (context, statsProvider, child) {
                    final totalUsers = statsProvider.totalUsers;
                    return _buildManagementRow(
                      context: context,
                      icon: Pixel.users,
                      title: 'Our Users',
                      subtitle: '$totalUsers total users in the system',
                      buttonText: 'Manage Users',
                      onPressed: () {
                        // TODO: Navigate to all users screen
                      },
                    );
                  },
                ),

                const SizedBox(height: 24),

                // reported items card
                _buildSectionTitle(context, 'Reported Items'),
                const SizedBox(height: 8),
                // Consumer for reported items provider later!!!!
                _buildManagementRow(
                  context: context,
                  icon: Pixel.flag,
                  title: 'Reported Items',
                  subtitle: '0 items awaiting review',
                  buttonText: 'Manage Reported Items',
                  onPressed: () {
                    // TODO: Navigate to reports screen
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // for section titles
  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        // style: Theme.of(
        //   context,
        // ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  // coach requests big container card
  Widget _buildCoachRequestsCard(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Consumer<AdminUsersProvider>(
        builder: (context, usersProvider, child) {
          if (usersProvider.isLoading && usersProvider.allUsers.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (usersProvider.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Error: ${usersProvider.errorMessage}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            );
          }
          final coaches = usersProvider.allUsers
              .where((user) => user.role == 'coach')
              .toList();

          if (coaches.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No pending coach requests.')),
            );
          }

          return Column(
            children: [
              ListView.builder(
                itemCount: coaches.take(3).length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  return _buildUserRequestTile(coaches[index], context);
                },
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerColor.withValues(alpha: 0.2),
              ),

              // BUTTON HERE
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to full coach requests screen
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(24.0),
                    foregroundColor: theme.colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  child: const Text(
                    'See All Requests',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // individul coach request tile
  Widget _buildUserRequestTile(UserModel user, BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(Pixel.user, color: theme.colorScheme.primary),
          ),
          title: Text(
            user.username,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(user.email, style: theme.textTheme.bodyMedium),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to coach approval detail screen
          },
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: theme.scaffoldBackgroundColor,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  // temporary cards for both user management and reported items
  Widget _buildManagementRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: theme.cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: theme.textTheme.bodyMedium?.color,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        // Manually set the color based on the theme
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    // Text(
                    //   title,
                    //   style: theme.textTheme.titleMedium?.copyWith(
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),

          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(24.0),
                foregroundColor: theme.colorScheme.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
