import 'package:flutter/material.dart';
import 'package:focusflow/models/connection_request_model.dart';
import 'package:focusflow/models/user_model.dart';
import 'package:focusflow/providers/coach_provider.dart';
import 'package:focusflow/screens/coach/coach_user_report_screen.dart';
import 'package:focusflow/widgets/styled_card.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachUserManagementScreen extends StatelessWidget {
  const CoachUserManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Use Consumer to get the data and listen for changes
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<CoachProvider>(
        builder: (context, coachProvider, child) {
          final pendingRequests = coachProvider.pendingRequests;
          final connectedUsers = coachProvider.connectedUsers;

          if (coachProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- PENDING REQUESTS SECTION ---
                Text(
                  'Pending Requests',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                StyledCard(
                  padding: pendingRequests.isEmpty
                      ? const EdgeInsets.all(16)
                      : const EdgeInsets.symmetric(vertical: 8),
                  child: pendingRequests.isEmpty
                      ? Text(
                          'No pending requests.',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        )
                      : Column(
                          children: pendingRequests.map((req) {
                            // This is the helper widget we moved
                            return _buildRequestTile(context, req);
                          }).toList(),
                        ),
                ),
                
                const SizedBox(height: 30),

                // --- CONNECTED USERS SECTION ---
                Text(
                  'Connected Users',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                StyledCard(
                  padding: connectedUsers.isEmpty
                      ? const EdgeInsets.all(16)
                      : EdgeInsets.zero,
                  child: connectedUsers.isEmpty
                      ? Text(
                          'You have no connected users.',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        )
                      : Column(
                          children: connectedUsers.map((user) {
                            // A new helper for showing connected users
                            return _buildConnectedUserTile(context, user);
                          }).toList(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- THIS IS THE HELPER WIDGET YOU MOVED ---
  Widget _buildRequestTile(BuildContext context, ConnectionRequestModel request) {
    // Use read here since it's in response to a user action
    final coachProvider = context.read<CoachProvider>(); 
    return ListTile(
      title: Text("${request.username} wants to connect."),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Pixel.check, color: Colors.green),
            onPressed: () {
              coachProvider.approveConnectionRequest(request.id, request.userId);
            },
          ),
          IconButton(
            icon: const Icon(Pixel.close, color: Colors.red),
            onPressed: () {
              coachProvider.rejectConnectionRequest(request.id);
            },
          ),
        ],
      ),
    );
  }

  // --- NEW HELPER WIDGET FOR YOUR CONNECTED USERS ---
  Widget _buildConnectedUserTile(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    return ListTile(
      leading: const Icon(Pixel.user),
      title: Text(user.username),
      subtitle: Text('Streak: ${user.currentStreak ?? 0} days'),
      trailing: Icon(Pixel.chevronright, color: theme.textTheme.bodyMedium?.color),
      onTap: () {
        // This can navigate to the same report screen as your AI Highlights
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoachUserReportScreen(
              userId: user.uid,
            ),
          ),
        );
      },
    );
  }
}