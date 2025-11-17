import 'package:flutter/material.dart';
import 'package:focusflow/models/notification_model.dart';
import 'package:focusflow/providers/notification_provider.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'admin_notify_screen.dart';

class AdminNotificationViewScreen extends StatelessWidget {
  const AdminNotificationViewScreen({super.key});

  List<AppNotification> _filterNotifications(
    List<AppNotification> list,
    NotificationFilter timeFilter,
    String roleFilter,
  ) {
    final now = DateTime.now();
    List<AppNotification> timeFilteredList;

    switch (timeFilter) {
      case NotificationFilter.week:
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        timeFilteredList = list
            .where((n) => n.sentAt.isAfter(sevenDaysAgo))
            .toList();
        break;
      case NotificationFilter.month:
        timeFilteredList = list
            .where(
              (n) => n.sentAt.year == now.year && n.sentAt.month == now.month,
            )
            .toList();
        break;
      case NotificationFilter.year:
        timeFilteredList = list
            .where((n) => n.sentAt.year == now.year)
            .toList();
        break;
      case NotificationFilter.all:
      default:
        timeFilteredList = list;
    }

    if (roleFilter == 'all') {
      return timeFilteredList;
    }
    return timeFilteredList.where((n) => n.target == roleFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            color: theme.scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Row(
                  children: [
                    Text(
                      'Broadcast System',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Filter by: ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<NotificationFilter>(
                          value: provider.selectedFilter,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          iconEnabledColor: theme.colorScheme.onSurface
                              .withOpacity(0.7),
                          dropdownColor: theme.cardColor,
                          underline: Container(height: 0),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<NotificationProvider>().updateFilter(
                                value,
                              );
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: NotificationFilter.all,
                              child: Text('All Time'),
                            ),
                            DropdownMenuItem(
                              value: NotificationFilter.week,
                              child: Text('This Week'),
                            ),
                            DropdownMenuItem(
                              value: NotificationFilter.month,
                              child: Text('This Month'),
                            ),
                            DropdownMenuItem(
                              value: NotificationFilter.year,
                              child: Text('This Year'),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: provider.selectedRoleFilter,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          iconEnabledColor: theme.colorScheme.onSurface
                              .withOpacity(0.7),
                          dropdownColor: theme.cardColor,
                          underline: Container(height: 0),
                          onChanged: (value) {
                            if (value != null) {
                              context
                                  .read<NotificationProvider>()
                                  .updateRoleFilter(value);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Roles'),
                            ),
                            DropdownMenuItem(
                              value: 'user',
                              child: Text('Users'),
                            ),
                            DropdownMenuItem(
                              value: 'coach',
                              child: Text('Coaches'),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Create Button
                    PrimaryButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdminNotifyScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.black,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        textStyle: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Pixel.plus, size: 20),
                          SizedBox(width: 8),
                          Text('Create'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Scrolling List of Notifications
          Expanded(
            child: StreamBuilder<List<AppNotification>>(
              stream: provider.getAllNotificationsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No notifications found.'));
                }

                final allNotifications = snapshot.data!;
                final currentTimeFilter = provider.selectedFilter;
                final currentRoleFilter = provider.selectedRoleFilter;
                final filteredList = _filterNotifications(
                  allNotifications,
                  currentTimeFilter,
                  currentRoleFilter,
                );

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Text('No notifications match this filter.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final notification = filteredList[index];
                    return _buildNotificationCard(context, notification, theme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: StyledCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    notification.target.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notification.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              DateFormat('MMM dd, yyyy  h:mm a').format(notification.sentAt),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
