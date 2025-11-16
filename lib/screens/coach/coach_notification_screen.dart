import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:focusflow/providers/providers.dart';

class CoachNotificationScreen extends StatelessWidget {
  const CoachNotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        titleTextStyle: theme.appBarTheme.titleTextStyle,
        iconTheme: theme.appBarTheme.iconTheme,
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: StreamBuilder(
        stream: context
            .read<NotificationProvider>()
            .getNotificationsStream("coach"),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                "No notifications yet.",
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          // Sort newest first
          notifications.sort(
            (a, b) => b.sentAt.compareTo(a.sentAt),
          );

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = notifications[index];

              return StyledCard(
                title: n.title,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateTime(n.sentAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      n.message,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year} • "
        "${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }
}
