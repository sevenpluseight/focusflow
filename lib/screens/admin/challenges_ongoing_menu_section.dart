import 'package:flutter/material.dart';
import 'package:focusflow/models/challenge_model.dart';
import 'package:focusflow/providers/challenge_provider.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class OngoingChallengesSection extends StatelessWidget {
  const OngoingChallengesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<ChallengeModel>>(
      stream: context.watch<ChallengeProvider>().getOngoingChallengesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final challenges = snapshot.data ?? [];

        if (challenges.isEmpty) {
          return const StyledCard(
            child: Center(child: Text('No ongoing challenges.')),
          );
        }

        return Column(
          children: challenges
              .take(6)
              .map(
                (challenge) =>
                    _buildOngoingChallengeCard(challenge, theme, context),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildOngoingChallengeCard(
    ChallengeModel challenge,
    ThemeData theme,
    BuildContext context,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final endDate = DateFormat('MMM dd').format(challenge.endDate!.toDate());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: StyledCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Pixel.clock,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  '${challenge.focusGoalHours} Hour Goal',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
                const Spacer(),
                Icon(
                  Pixel.calendar,
                  size: 16,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ends $endDate',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
