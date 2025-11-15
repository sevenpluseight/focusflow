import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/screens/coach/coach.dart';
import 'package:focusflow/widgets/widgets.dart';
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
    
    // Fetch both users and challenges
    await coachProvider.fetchConnectedUsers(coachId);
    await coachProvider.fetchMyChallenges();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // We use "watch" to listen for data changes
    final coachProvider = context.watch<CoachProvider>();
    
    // --- Calculate Stats ---
    final users = coachProvider.connectedUsers;
    final challenges = coachProvider.challenges;

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
            Text(
              'Pending User Requests',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            StyledCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO: Implement Pending Requests Logic
                  Text(
                    'No pending requests.',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'View More >',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'Quick Stats',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            StyledCard(
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

            Text(
              'AI Highlights (At-Risk Users)',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            StyledCard(
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

  // Helper widget to build the At-Risk user tile
  Widget _buildAtRiskTile(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(Pixel.alert, color: theme.colorScheme.tertiary),
      title: Text(
        'Alert: ${user.username} is at risk.',
        style: TextStyle(
          color: theme.colorScheme.tertiary,
          fontSize: 16,
          height: 1.5,
        ),
      ),
      subtitle: const Text('Streak has reset to 0 days.'),
      trailing: Icon(Pixel.chevronright, color: theme.textTheme.bodyMedium?.color),
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
