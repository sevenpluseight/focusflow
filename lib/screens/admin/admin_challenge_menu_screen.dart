import 'package:flutter/material.dart';
import 'package:focusflow/screens/admin/admin.dart';
import 'package:focusflow/widgets/widgets.dart';

class AdminChallengeMenuScreen extends StatelessWidget {
  const AdminChallengeMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminMenuSectionTitle('Challenge Requests'),
                const SizedBox(height: 8),
                const ChallengeRequestsSection(),
                const SizedBox(height: 24),

                const AdminMenuSectionTitle('Ongoing Challenges'),
                const SizedBox(height: 8),
                const OngoingChallengesSection(),
                const SizedBox(height: 24),

                PrimaryButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdminApprovedChallengesScreen(),
                      ),
                    );
                  },
                  child: const Text('View All Challenges'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
