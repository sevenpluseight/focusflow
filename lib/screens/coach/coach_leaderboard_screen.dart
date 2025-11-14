import 'package:flutter/material.dart';
import 'package:focusflow/models/models.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class CoachLeaderboardScreen extends StatelessWidget {
  const CoachLeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final coachProvider = context.watch<CoachProvider>();

    // Sort the connected users by their streak (descending)
    final rankedUsers = List<UserModel>.from(coachProvider.connectedUsers);
    rankedUsers.sort((a, b) => (b.currentStreak ?? 0).compareTo(a.currentStreak ?? 0));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: isDark ? const Color(0xFF3A3D42) : const Color(0xFFE8F5E9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Pixel.chevronleft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Top Performers" Card (Figure 23)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StyledCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTopPerformer(
                    theme,
                    rank: 1,
                    user: rankedUsers.isNotEmpty ? rankedUsers[0] : null,
                  ),
                  _buildTopPerformer(
                    theme,
                    rank: 2,
                    user: rankedUsers.length > 1 ? rankedUsers[1] : null,
                  ),
                  _buildTopPerformer(
                    theme,
                    rank: 3,
                    user: rankedUsers.length > 2 ? rankedUsers[2] : null,
                  ),
                ],
              ),
            ),
          ),

          // "Participant Rankings" List (Figure 23)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Participant Rankings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: rankedUsers.isEmpty
                ? Center(
                    child: Text(
                      'No users to rank yet.',
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                    ),
                  )
                : ListView.builder(
                    itemCount: rankedUsers.length,
                    itemBuilder: (context, index) {
                      final user = rankedUsers[index];
                      return _buildRankCard(theme, user, index + 1);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Helper for the top 3
  Widget _buildTopPerformer(ThemeData theme, {required int rank, UserModel? user}) {
    String name = 'N/A';
    String score = '0';
    IconData icon = Pixel.user;
    Color color = Colors.grey;

    if (user != null) {
      name = user.username;
      score = '${user.currentStreak ?? 0} days';
    }

    if (rank == 1) {
      icon = Pixel.moodhappy;
      color = Colors.amber;
    } else if (rank == 2) {
      icon = Pixel.moodneutral;
      color = Colors.grey.shade400;
    } else if (rank == 3) {
      icon = Pixel.moodsad;
      color = const Color(0xFFCD7F32); // Bronze
    }

    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          score,
          style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        ),
      ],
    );
  }

  // Helper for the rest of the list
  Widget _buildRankCard(ThemeData theme, UserModel user, int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: StyledCard(
        child: Row(
          children: [
            Text(
              '#$rank',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              user.username,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Text(
              '${user.currentStreak ?? 0} days',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}