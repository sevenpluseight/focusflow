import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class UserChallengesScreen extends StatelessWidget {
  const UserChallengesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final challenges = challengeProvider.approvedChallenges;
    final userProvider = context.watch<UserProvider>();
    final userId = userProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: challengeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : challengeProvider.errorMessage != null
              ? Center(child: Text(challengeProvider.errorMessage!))
              : challenges.isEmpty
                  ? const Center(child: Text('No approved challenges yet.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: challenges.length,
                      itemBuilder: (context, index) {
                        final challenge = challenges[index];
                        final createdAt =
                            DateFormat('MMM d, yyyy').format(challenge.createdAt.toDate());

                        // Calculate durationDays if startDate and endDate are available
                        int? durationDays;
                        if (challenge.startDate != null && challenge.endDate != null) {
                          final start = challenge.startDate!.toDate();
                          final end = challenge.endDate!.toDate();
                          durationDays = end.difference(start).inDays;
                        }

                        // Participants list (non-nullable)
                        final participants = challenge.participants;
                        final hasJoined = userId != null && participants.contains(userId);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: StyledCard(
                            title: challenge.name,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Created At: $createdAt'),
                                Text('Focus Goal Hours: ${challenge.focusGoalHours}'),
                                if (durationDays != null)
                                  Text('Duration: $durationDays days'),
                                Text('Description: ${challenge.description}'),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: PrimaryButton(
                                    onPressed: hasJoined || userId == null
                                        ? null
                                        : () async {
                                            try {
                                              await challengeProvider.joinChallenge(
                                                  challenge.id, userId);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Successfully joined challenge!'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error joining challenge: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                    child: Text(hasJoined ? 'Joined' : 'Join'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
