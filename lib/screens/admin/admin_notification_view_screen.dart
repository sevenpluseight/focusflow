import 'package:flutter/material.dart';
import 'package:focusflow/models/notification_model.dart';
import 'package:focusflow/providers/notification_provider.dart';
import 'package:focusflow/widgets/widgets.dart'; // Has StyledCard, PrimaryButton etc.
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

// Make sure you have a screen to navigate to
import 'admin_notify_screen.dart'; // The "create" page you already built

class AdminNotificationViewScreen extends StatelessWidget {
  const AdminNotificationViewScreen({super.key});

  /// Helper method to filter the list *after* it's fetched
  List<AppNotification> _filterNotifications(
    List<AppNotification> list,
    NotificationFilter filter,
  ) {
    // ... (This function is correct, no changes needed) ...
    final now = DateTime.now();

    switch (filter) {
      case NotificationFilter.week:
        // A simple "last 7 days" filter is easier
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        return list.where((n) => n.sentAt.isAfter(sevenDaysAgo)).toList();
      case NotificationFilter.month:
        return list
            .where(
              (n) => n.sentAt.year == now.year && n.sentAt.month == now.month,
            )
            .toList();
      case NotificationFilter.year:
        return list.where((n) => n.sentAt.year == now.year).toList();
      case NotificationFilter.all:
      default:
        return list;
    }
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
          // 1. Non-scrolling Header Container
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.cardColor,
            // Use a Column as the main child
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Row 1: Title ---
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
                const SizedBox(height: 16), // Space between the rows
                // --- Row 2: Filter and Create Button ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Filter Dropdown
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
                        minimumSize: Size.zero, // Allow button to shrink
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
                final currentFilter = provider.selectedFilter;
                final filteredList = _filterNotifications(
                  allNotifications,
                  currentFilter,
                );

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Text('No notifications match this filter.'),
                  );
                }

                return ListView.builder(
                  // Add padding to the list, not the whole body
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
      // --- End Fix 2 ---
    );
  }

  /// Helper to build the card using your StyledCard
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
