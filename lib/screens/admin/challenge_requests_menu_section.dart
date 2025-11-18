import 'package:flutter/material.dart';
import 'package:focusflow/models/challenge_model.dart';
import 'package:focusflow/providers/challenge_provider.dart';
import 'package:focusflow/screens/admin/admin.dart';
import 'package:focusflow/widgets/widgets.dart';
import 'package:pixelarticons/pixelarticons.dart';
import 'package:provider/provider.dart';

class ChallengeRequestsSection extends StatelessWidget {
  const ChallengeRequestsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StyledCard(
      padding: EdgeInsets.zero,
      child: StreamBuilder<List<ChallengeModel>>(
        stream: context.watch<ChallengeProvider>().getPendingChallengesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            );
          }

          final requests = snapshot.data ?? [];

          return Column(
            children: [
              if (requests.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No pending challenges.')),
                )
              else
                ListView.builder(
                  itemCount: requests.take(3).length, // Show top 3
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return _buildChallengeRequestTile(requests[index], context);
                  },
                ),
              Divider(
                height: 1,
                thickness: 1,
                color: theme.dividerColor.withOpacity(0.2),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            const AdminPendingChallengesScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(24.0),
                    foregroundColor: theme.colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  child: const Text(
                    'See All Requests',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChallengeRequestTile(
    ChallengeModel request,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            child: Icon(Pixel.bookopen, color: theme.colorScheme.primary),
          ),
          title: Text(
            request.name,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${request.focusGoalHours} hours',
            style: theme.textTheme.bodyMedium,
          ),
          trailing: const Icon(Pixel.chevronright),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ChallengeRequestDetailsSheet(request: request),
            );
          },
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: theme.scaffoldBackgroundColor,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}
