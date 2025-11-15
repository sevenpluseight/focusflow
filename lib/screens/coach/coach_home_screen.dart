import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/coach/coach.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({Key? key}) : super(key: key);

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    // We use "read" inside initState
    final authProvider = context.read<AuthProvider>();
    final coachProvider = context.read<CoachProvider>();
    final coachId = authProvider.user?.uid ?? '';
    
    // Fetch all coach data in parallel
    await Future.wait([
      coachProvider.fetchConnectedUsers(coachId),
      coachProvider.fetchMyChallenges(),
      coachProvider.fetchPendingRequests() // <-- ADD THIS
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // We use "watch" to listen for data changes
    final coachProvider = context.watch<CoachProvider>();
    
    // --- Get all data ---
    final users = coachProvider.connectedUsers;
    final challenges = coachProvider.challenges;
    final pendingRequests = coachProvider.pendingRequests; // <-- GET REQUESTS

    // --- Calculate Stats ---
    final totalUsers = users.length;
    final atRiskUsers = users.where((u) => (u.currentStreak ?? 0) == 0).toList();
    
    double totalStreak = 0;
    for (var user in users) {
      totalStreak += (user.currentStreak ?? 0);
    }
    final avgStreak = (totalUsers > 0) ? (totalStreak / totalUsers) : 0.0;
    // -----------------------

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Pending User Requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            
            // --- THIS IS THE FIXED CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: coachProvider.isLoading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ))
                  : pendingRequests.isEmpty
                      ? Text(
                          'No pending requests.',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        )
                      : Column(
                          children: pendingRequests.map((req) {
                            return _buildRequestTile(context, req);
                          }).toList(),
                        ),
            ),
            // -------------------------------

            const SizedBox(height: 30),

            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: coachProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• Total Users Coached: $totalUsers',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          '• Average Streak: ${avgStreak.toStringAsFixed(1)} days',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          '• Ongoing Challenges: ${challenges.length}',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 30),

            const Text(
              'AI Highlights (At-Risk Users)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: coachProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : atRiskUsers.isEmpty
                      ? Text(
                          'Great job! No users are currently at risk.',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        )
                      : Column(
                          // Build the list dynamically
                          children: atRiskUsers.map((user) {
                            return _buildAtRiskTile(context, user);
                          }).toList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
  
  // --- ADD THIS HELPER WIDGET ---
  Widget _buildRequestTile(BuildContext context, ConnectionRequestModel request) {
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

  // Helper widget to build the At-Risk user tile
  Widget _buildAtRiskTile(BuildContext context, UserModel user) {
    return ListTile(
      leading: const Icon(Pixel.alert, color: Colors.orangeAccent),
      title: Text(
        'Alert: ${user.username} is at risk.',
        style: const TextStyle(
          color: Colors.orangeAccent,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      subtitle: const Text('Streak has reset to 0 days.'),
      trailing: const Icon(Pixel.chevronright, color: Colors.grey),
      onTap: () {
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