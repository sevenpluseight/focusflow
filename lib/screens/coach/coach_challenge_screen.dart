import 'package:flutter/material.dart';
import 'package:pixelarticons/pixelarticons.dart';

import 'package:focusflow/screens/coach/coach.dart';

class CoachChallengeScreen extends StatelessWidget {
  const CoachChallengeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Create New Challenge Button
            _buildChallengeButton(
              theme: theme,
              icon: Pixel.plus,
              label: 'Create New Challenge',
              onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CoachCreateChallengeScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
            // Check Leaderboard Button
            _buildChallengeButton(
              theme: theme,
              icon: Pixel.chartmultiple,
              label: 'Check Leaderboard',
              onTap: () {
                // TODO: Navigate to Leaderboard (Figure 23)
              },
            ),
            const SizedBox(height: 16),

            // Ongoing Challenges Button
            _buildChallengeButton(
              theme: theme,
              icon: Pixel.clock,
              label: 'Ongoing Challenges',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CoachOngoingChallengesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build the large buttons
  Widget _buildChallengeButton({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardColor, // This will use your theme color
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.onSurface),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Icon(Pixel.chevronright, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}