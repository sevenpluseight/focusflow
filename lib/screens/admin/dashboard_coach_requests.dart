import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachRequestsSection extends StatelessWidget {
  const CoachRequestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StyledCard(
      padding: EdgeInsets.zero,
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

          // Note: This logic seems to get coaches, not *requests*.
          // You may want to filter for user.role == 'user' and
          // user.isRequestingCoach == true in the future.
          // For now, I am keeping your exact logic.
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
                color: theme.dividerColor.withOpacity(0.2),
              ),
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

  // This is the private helper, co-located in the same file.
  Widget _buildUserRequestTile(UserModel user, BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
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
            // ADD HERE LATER
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
}
