import 'package:flutter/material.dart';
import 'package:focusflow/providers/providers.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';
import 'package:focusflow/screens/user/user.dart';
import 'package:focusflow/widgets/widgets.dart';

class UserCoachesScreen extends StatelessWidget {
  const UserCoachesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.watch<UserProvider>();
    final connectedCoach = userProvider.connectedCoach;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Coach & Challenges'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOptionCard(
              theme: theme,
              icon: Pixel.users,
              label: connectedCoach != null ? 'My Coach' : 'Connect with Coach',
              onTap: () {
                if (connectedCoach != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserMessagesScreen(
                        coachId: connectedCoach.userId,
                        coachName: connectedCoach.fullName,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FindCoachScreen()),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            // Challenges
            _buildOptionCard(
              theme: theme,
              icon: Pixel.trophy,
              label: 'Challenges',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserChallengesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: StyledCard(
        padding: const EdgeInsets.all(24),
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
