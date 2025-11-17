import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class UserJoinedChallengesScreen extends StatelessWidget {
  const UserJoinedChallengesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final userProvider = context.watch<UserProvider>();
    final userId = userProvider.user?.uid;

    final joinedChallenges = challengeProvider.approvedChallenges
        .where((challenge) => challenge.participants.contains(userId))
        .toList();

    final theme = Theme.of(context);
    // final textColor = theme.colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Challenges'),
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: challengeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : joinedChallenges.isEmpty
              ? const Center(child: Text('No challenges joined yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: joinedChallenges.length,
                  itemBuilder: (context, index) {
                    final challenge = joinedChallenges[index];
                    final bool hasEnded = challenge.endDate != null &&
                        challenge.endDate!.toDate().isBefore(DateTime.now());
                    final Color cardColor = hasEnded
                        ? theme.colorScheme.surfaceVariant
                        : theme.cardColor;

                    int? durationDays;
                    if (challenge.startDate != null && challenge.endDate != null) {
                      final start = challenge.startDate!.toDate();
                      final end = challenge.endDate!.toDate();
                      durationDays = end.difference(start).inDays;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () {
                          // No navigation
                        },
                        child: StyledCard(
                          color: cardColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                challenge.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                  'Created At: ${DateFormat('MMM d, yyyy').format(challenge.createdAt.toDate())}'),
                              if (durationDays != null)
                                Text('Duration: $durationDays days'),
                              Text('Focus Goal Hours: ${challenge.focusGoalHours}'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
