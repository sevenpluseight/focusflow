import 'package:flutter/material.dart';
import 'package:focusflow/models/challenge_model.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
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
    final coachProvider = context.watch<CoachProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ongoing Challenges'),
        backgroundColor: theme.appBarTheme.backgroundColor,
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
    Color onStatusColor;

    switch (challenge.status) {
      case 'approved':
        statusColor = Colors.green.shade600;
        onStatusColor = Colors.white;
        break;
      case 'rejected':
        statusColor = theme.colorScheme.error;
        onStatusColor = theme.colorScheme.onError;
        break;
      default: // pending
        statusColor = theme.colorScheme.tertiary;
        onStatusColor = theme.colorScheme.onTertiary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: StyledCard(
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
                    style: TextStyle(
                      color: onStatusColor,
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