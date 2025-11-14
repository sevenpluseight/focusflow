import 'package:flutter/material.dart';
import 'package:focusflow/models/challenge_model.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachOngoingChallengesScreen extends StatefulWidget {
  const CoachOngoingChallengesScreen({Key? key}) : super(key: key);

  @override
  State<CoachOngoingChallengesScreen> createState() => _CoachOngoingChallengesScreenState();
}

class _CoachOngoingChallengesScreenState extends State<CoachOngoingChallengesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachProvider>().fetchMyChallenges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final coachProvider = context.watch<CoachProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ongoing Challenges'),
        backgroundColor: isDark ? const Color(0xFF3A3D42) : const Color(0xFFE8F5E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: coachProvider.challengesLoading
          ? const Center(child: CircularProgressIndicator())
          : coachProvider.challenges.isEmpty
              ? Center(
                  child: Text(
                    'You have not created any challenges yet.',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: coachProvider.challenges.length,
                  itemBuilder: (context, index) {
                    final challenge = coachProvider.challenges[index];
                    return _buildChallengeCard(theme, challenge);
                  },
                ),
    );
  }

  // This widget matches Figure 24 
  Widget _buildChallengeCard(ThemeData theme, ChallengeModel challenge) {
    Color statusColor;
    switch (challenge.status) {
      case 'approved':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default: // pending
        statusColor = Colors.orange;
    }

    return Card(
      color: theme.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  challenge.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    challenge.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Focus Goal: ${challenge.focusGoalHours} hours',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
            Text(
              'Duration: ${challenge.durationDays} days',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            ),
          ],
        ),
      ),
    );
  }
}